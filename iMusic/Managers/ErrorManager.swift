//
//  Errors.swift
//  iMusic
//
//  Created by rigo on 20/07/2019.
//  Copyright © 2019 Igor Shuvalov. All rights reserved.
//

enum ErrorType<T> {
    // NETWORK issues
    case missingHTTPResponse
    case wrongResponseStatusCode(T)
    case nullResponseData
    case nullParseData
    case fetchingError(T)
    case parsingJSONData(T)
    
    var code: Int {
        switch self {
        case .missingHTTPResponse: return 100
        case .wrongResponseStatusCode: return 101
        case .nullResponseData: return 102
        case .nullParseData: return 103
        case .fetchingError: return 104
        case .parsingJSONData: return 105
        }
    }
    
    var description: String {
        switch self {
        case .missingHTTPResponse:
            return "missing HTTP Response"
        case .wrongResponseStatusCode(let code):
            return "wrong Response StatusCode=\(code)"
        case .nullResponseData:
            return "null ResponseData"
        case .nullParseData:
            return "null Parse Data"
        case .fetchingError(let error):
            return "fetching error = \(error)"
        case .parsingJSONData(let error):
            return "parsing JSONData error = \(error)"
        }
    }
}

struct AppError: Error {
    let type: ErrorType<Any>
    let file: String
    let function: String
    let supplement: String
    
    var description: String {
        return """
        Error:
        code = \(type.code)
        description: \(type.description)
        
        file: \(file)
        function: \(function)
        supplement: \(supplement)
        """
    }
    
    init(type: ErrorType<Any>, file: String, function: String, supplement: String = "") {
        self.type = type
        self.file = file
        self.function = function
        self.supplement = supplement
    }
}
