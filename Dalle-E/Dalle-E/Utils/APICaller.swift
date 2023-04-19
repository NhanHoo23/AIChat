//
//  APICaller.swift
//  Dalle-E
//
//  Created by Nhan Ho on 09/02/2023.
//

import MTSDK
import OpenAIKit

class API {
    static let shared = API()
    
    let key = "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"
    var client: OpenAI?
    
    func setup() {
        client = OpenAI(Configuration(organization: "Personal", apiKey: key))
    }
    
    func getResponse(input: String) async -> String{
        guard let client = client else {return ""}
        
        do {
            let params = CompletionParameters(model: OpenAIModelType.gpt3(.davinci).modelName,
                                              prompt: [input],
                                              maxTokens: 4000,
                                              temperature: 0.9)
            let completionResponse = try await client.generateCompletion(parameters: params)
            let responseText = completionResponse.choices.map { $0.text.trimming()}.joined()
            print("responseText: \(responseText)")
            
            return responseText
        }
        catch {
            print(String(describing: error))
            return ""
        }
    }
    
    func generateImage(prompt: String) async -> [UIImage]? {
        guard let openai = client else {return nil}
        
        do {
            let params = ImageParameters(prompt: prompt,
                                         numberofImages: 4,
                                         resolution: .medium,
                                         responseFormat: .base64Json)
            let results = try await openai.createImage(parameters: params)
            let b64Images = results.data.map { $0.image }
            let images = b64Images.compactMap({
                try? openai.decodeBase64Image($0)
            })
            
            print("results: \(images.count)")
            
            return images
        } catch {
            print(String(describing: error))
            return nil
        }
    }
}
