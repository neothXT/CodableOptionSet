//
//  COSDiagnostics.swift
//  
//
//  Created by Maciej Burdzicki on 04/10/2023.
//

import Foundation
import SwiftSyntax
import SwiftDiagnostics
import SwiftSyntaxBuilder

enum CodableOptionSetError: COSDiagnostics, CustomStringConvertible, Error {
    case badInheritance
    
    var domain: String { "CodableOptionSet macro" }
    
    var description: String {
        switch self {
        case .badInheritance:
            return "@CodableOptionSet can only be applied to a struct which conforms to 'OptionSet' protocol"
        }
    }
}

protocol COSDiagnostics {
    var domain: String { get }
    var description: String { get }
    func diagnostic(for node: SyntaxProtocol, severity: DiagnosticSeverity, fixIts: [FixIt]) -> Diagnostic
}

extension COSDiagnostics {
    func diagnostic(for node: SyntaxProtocol, severity: DiagnosticSeverity = .error, fixIts: [FixIt] = []) -> Diagnostic {
        .init(
            node: Syntax(node),
            message: COSDiagnosticMessage(
                diagnosticID: .init(domain: domain,id: String(describing: self)),
                message: description, severity: severity),
            fixIts: fixIts)
    }
}

fileprivate struct COSDiagnosticMessage: DiagnosticMessage {
    var diagnosticID: MessageID
    var message: String
    var severity: DiagnosticSeverity
}
