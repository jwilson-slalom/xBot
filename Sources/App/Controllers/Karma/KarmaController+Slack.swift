//
//  KarmaController+Slack.swift
//  App
//
//  Created by Jacob Wilson on 3/7/19.
//

import Vapor
import struct SlackKit.User

extension KarmaController: CommandCollection {
    func boot(router: SlackRouter, env: Environment) throws {
        router.registerCommandResponder(for: [.message], responder: KarmaAdjustmentResponder(), use: handleKarmaAdjustmentCommand)
        router.registerCommandResponder(for: [.message], responder: KarmaStatusResponder(), use: handleKarmaStatusCommand)
        router.registerCommandResponder(for: [.message], responder: KarmaLeaderboardResponder(), use: handleKarmaLeaderboardCommand)

        // TODO: Move this out of KarmaController as it won't always be constrained to Karma help commands
        router.registerCommandResponder(for: [.message], responder: KarmaHelpResponder(isRelease: env.isRelease), use: handleKarmaHelpCommand)
    }
}

// MARK: Command Handling
extension KarmaController {
    func handleKarmaAdjustmentCommand(_ karmaAdjustmentCommand: KarmaAdjustmentCommand, forBotUser: User) throws {
        let incomingMessage = karmaAdjustmentCommand.incomingMessage
        let slack = self.slack
        let statusRepository = self.karmaStatusRepository
        let historyRepository = self.karmaHistoryRepository
        let log = self.log

        try karmaAdjustmentCommand.adjustments.forEach { adjustment in

            guard adjustment.user != incomingMessage.sender else {
                let errorMessage = "You can't adjust karma for yourself!"
                try slack.send(message: SlackKitResponse(to: incomingMessage, text: errorMessage), onlyVisibleTo: incomingMessage.sender)
                return
            }

            // Save history record
            let karmaHistory = KarmaSlackHistory(karmaCount: adjustment.count, karmaReceiver: adjustment.user, karmaSender: incomingMessage.sender, inChannel: incomingMessage.channelID.id)
            historyRepository
                .save(history: karmaHistory)
                .catch {
                    log.error("Could not save history \($0)")
                }

            // Update karma
            statusRepository
                .find(id: adjustment.user)
                .flatMap {
                    statusRepository.save(karma: KarmaStatus(id: adjustment.user, count: ($0?.count ?? 0) + adjustment.count))
                }.thenThrowing { updatedStatus -> Void in
                    try slack.send(message: KarmaStatusResponse(forKarmaAdjustingMessage: incomingMessage, receivedKarma: adjustment, statusAfterChange: updatedStatus))
                }.catchMap { error in
                    let errorMessage = "Something went wrong. Please try again"
                    try slack.send(message: SlackKitResponse(to: incomingMessage, text: errorMessage), onlyVisibleTo: incomingMessage.sender)
                }.catch {
                    log.error("Completely unhandled Karma error occurred. This is bad, so bad: \($0)")
                }
        }
    }

    func handleKarmaStatusCommand(_ karmaStatusCommand: KarmaStatusCommand, forBotUser: User) throws {
        let statuses = karmaStatusRepository.find(ids: karmaStatusCommand.userIds)
        try handle(statuses: statuses, on: karmaStatusCommand.incomingMessage, forType: .status)
    }

    func handleKarmaLeaderboardCommand(_ karmaLeaderboardCommand: KarmaLeaderboardCommand, forBotUser: User) throws {
        let statuses = karmaStatusRepository.top(count: karmaLeaderboardCommand.leaderboardCount)
        try handle(statuses: statuses, on: karmaLeaderboardCommand.incomingMessage, forType: .leaderboard)
    }

    func handleKarmaHelpCommand(_ karmaHelpCommand: KarmaHelpCommand, forBotUser: User) throws {
        try slack.send(message: SlackHelpResponse(from: karmaHelpCommand))
    }

    private func handle(statuses: Future<[KarmaStatus]>, on incomingMessage: SlackKitIncomingMessage, forType type: KarmaCommandType) throws {
        let slack = self.slack

        statuses
            .thenThrowing {
                guard !$0.isEmpty else {
                    let message = "Couldn't find any karma!"
                    try slack.send(message: SlackKitResponse(to: incomingMessage, text: message))
                    return
                }

                let response = self.response(forType: type, on: incomingMessage, statuses: $0)
                try slack.send(message: response)
            }
            .catchMap { error in
                let errorMessage = "Something went wrong. Please try again"
                try slack.send(message: SlackKitResponse(to: incomingMessage, text: errorMessage))
            }
            .catch {
                self.log.error("Failed to respond to Slack slash command \($0)")
            }
    }

    private func response(forType type: KarmaCommandType, on incomingMessage: SlackKitIncomingMessage, statuses: [KarmaStatus]) -> KarmaStatusResponse {
        switch type {
        case .leaderboard:
            return KarmaStatusResponse(forKarmaLeaderboardMessage: incomingMessage, statuses: statuses)
        case .status:
            return KarmaStatusResponse(forKarmaStatusMessage: incomingMessage, statuses: statuses)
        }
    }

    private enum KarmaCommandType {
        case leaderboard
        case status
    }
}
