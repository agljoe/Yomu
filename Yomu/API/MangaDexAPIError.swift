//
//  MangaDexAPIError.swift
//  Yomu
//
//  Created by Andrew Joe on 2025-04-01.
//

import Foundation

/// An error response from the MangaDexApi.
///
/// The MangaDexApi specifies the exact repsonses for each enpoint, for more information see [MangaDex API Documentation](https://api.mangadex.org/docs/redoc.html).
public enum MangaDexAPIError: Error, Equatable, Hashable {
    case unknownResponse(context: String)
    case badRequest(context: String)
    case unauthorizedRequest(context: String)
    case forbiddenRequest(context: String)
    case notFound(context: String)
    case serviceUnavailable(context: String)
    case invalidURL(context: String)
}

extension MangaDexAPIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unknownResponse(let context):
            return String(localized: "Unknown response recived from server, context: \(context).")
        case .badRequest(let context):
            return String(localized: "Request could not be completed, likely because the format was incorrect, context: \(context).")
        case .unauthorizedRequest(let context):
            return String(localized: "Loged user is not authorized to make this request, context: \(context).")
        case .forbiddenRequest(let context):
            return String(localized: "Request not allowed, context: \(context).")
        case .notFound(let context):
            return String(localized: "Request target could not be found, context: \(context).")
        case .serviceUnavailable(let context):
            return String(localized: "Service is currently unavailable, context: \(context).")
        case .invalidURL(let context):
            return String(localized: "Could not find server at requested URL, context: \(context).")
        }
    }
}

/// Maps an `HTTPRespsonse` to the associated ``MDApiError``
/// - Parameters:
///     - response: an `HTTPURLResponse`
///     - context: a string describing the context in which the error happened
///
/// - Returns: an associated ``MDApiError``.
//func httpError(_ response: HTTPURLResponse, context: String) -> MDApiError {
//    switch response.statusCode {
//    case 400:
//        return MDApiError.badRequest(context: context)
//    case 401:
//        return MDApiError.unauthorizedRequest(context: context)
//    case 403:
//        return MDApiError.forbiddenRequest(context: context)
//    case 404:
//        return MDApiError.notFound(context: context)
//    case 503:
//        return MDApiError.serviceUnavailable(context: context)
//    default:
//        return MDApiError.unknownResponse(context: context)
//    }
//}
