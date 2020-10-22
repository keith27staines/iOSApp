
import Foundation
import WorkfinderNetworking
import WorkfinderCommon

open class WorkfinderService {
    public let networkConfig: NetworkConfig
    
    private var urlComponents: URLComponents
    private let taskHandler: DataTaskCompletionHandler
    private var session: URLSession { networkConfig.sessionManager.interactiveSession }
    private var task: URLSessionDataTask?
    lazy private var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    lazy private var encoder: JSONEncoder = {
        return JSONEncoder()
    }()
    
    public init(networkConfig: NetworkConfig) {
        self.networkConfig = networkConfig
        self.taskHandler = DataTaskCompletionHandler(logger: networkConfig.logger)
        self.urlComponents = URLComponents(url: networkConfig.workfinderApiV3Url, resolvingAgainstBaseURL: true)!
    }
    
    public func performTask<A:Decodable>(
        with request: URLRequest,
        completion: @escaping (Result<A,Error>) -> Void,
        attempting: String) {
        task?.cancel()
        task = buildTask(
            request: request,
            completion: completion,
            attempting: attempting)
        task?.resume()
    }
    
    public func buildRequest<A: Encodable>(relativePath: String?, verb: RequestVerb, body: A) throws -> URLRequest {
        var request = try buildRequest(relativePath: relativePath, queryItems: nil, verb: verb)
        request.httpBody = try encoder.encode(body)
        return request
    }
    
    public func buildRequest(relativePath: String?, queryItems: [URLQueryItem]?, verb: RequestVerb) throws -> URLRequest {
        var components = urlComponents
        components.path += relativePath ?? ""
        components.queryItems = queryItems
        guard let url = components.url else { throw WorkfinderError(errorType: .invalidUrl(components.path), attempting: #function, retryHandler: nil) }
        return networkConfig.buildUrlRequest(url: url, verb: verb, body: nil)
    }

    private func buildTask<ResponseJson:Decodable>(
        request: URLRequest,
        completion: @escaping ((Result<ResponseJson,Error>) -> Void),
        attempting: String) -> URLSessionDataTask {
        let task = session.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            guard let self = self else { return }
            self.taskHandler.convertToDataResult(
                attempting: attempting,
                request: request,
                responseData: data,
                httpResponse: response as? HTTPURLResponse,
                error: error) { [weak self] (result) in
                    self?.deserialise(dataResult: result, completion: completion)
                
            }
        })
        return task
    }
    
    private func deserialise<ResponseJson:Decodable>(dataResult: Result<Data,Error>, completion: ((Result<ResponseJson,Error>) -> Void)) {
        switch dataResult {
        case .success(let data):
            do {
                #if DEBUG
                print()
                print("--------------- Start Json capture --------------------")
                print("Deserialising \(ResponseJson.self) from...")
                prettyPrint(data: data)
                print("--------------- End Json capture ----------------------")
                print()
                #endif
                let json = try decoder.decode(ResponseJson.self, from: data)
                completion(Result<ResponseJson,Error>.success(json))
            } catch {
                let nsError = error as NSError
                let workfinderError = WorkfinderError(errorType: .deserialization(error), attempting: #function, retryHandler: nil)
                networkConfig.logger.logDeserializationError(
                    to: ResponseJson.self,
                    from: data,
                    error: nsError)
                completion(Result<ResponseJson,Error>.failure(workfinderError))
            }
        case .failure(let error):
            completion(Result<ResponseJson,Error>.failure(error))
        }
    }
    
    func prettyPrint(data: Data?) {
        guard let data = data else { return }
        if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) {
            if let prettyPrintedData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                let string = (String(bytes: prettyPrintedData, encoding: String.Encoding.utf8) ?? "")
                    .replacingOccurrences(of: "\\/", with: "/")
                    .replacingOccurrences(of: "\"", with: "\\\"")
                print(string)
           }
        }
    }
}


/*
 
 {
   \"previous\" : null,
   \"results\" : [
     {
       \"association\" : {
         \"title\" : \"\",
         \"host\" : {
           \"uuid\" : \"d5ecfbba-bd0e-4051-b285-be9f23abba2f\",
           \"full_name\" : \"Test User\",
           \"description\" : \"\",
           \"phone\" : \"\",
           \"associations\" : [
             \"c9430def-7847-42cc-b03a-298f54eb7599\"
           ],
           \"photo_thumbnails\" : null,
           \"names\" : [
             \"Test User\"
           ],
           \"twitter_handle\" : \"\",
           \"linkedin_url\" : \"\",
           \"friendly_name\" : \"\",
           \"emails\" : [
             \"barbara90@duncan.org\"
           ],
           \"instagram_handle\" : \"\",
           \"user\" : \"4d0cb9ba-c4ab-44a5-9650-934ab4858d7e\",
           \"photo\" : null,
           \"opted_into_marketing\" : false
         },
         \"location\" : {
           \"address_city\" : \"\",
           \"address_street\" : \"\",
           \"address_building\" : \"\",
           \"company\" : {
             \"name\" : \"company_1\",
             \"logo\" : null,
             \"uuid\" : \"9349b14e-5708-4db1-ac79-53c121cff344\"
           },
           \"uuid\" : \"a24383f6-0808-489e-a8a1-0ab1581529fb\",
           \"address_unit\" : \"\",
           \"address_region\" : \"\",
           \"address_country\" : \"AF\",
           \"address_postcode\" : \"\"
         }
       },
       \"recommender\" : {
         \"scorers\" : [
           {
             \"host_period\" : 90,
             \"placement_period\" : 30,
             \"weight\" : 0.10000000000000001,
             \"class\" : \"ActivityScorer\",
             \"weights\" : {
               \"accepted\" : 0.20000000000000001,
               \"viewed\" : 0.20000000000000001,
               \"created_recently\" : 0.5,
               \"time_since_last_log_in\" : 0.10000000000000001
             }
           },
           {
             \"class\" : \"ProjectBoosterScorer\",
             \"weight\" : 0.14999999999999999
           },
           {
             \"class\" : \"ProjectUCASScorer\",
             \"weight\" : 0.5
           },
           {
             \"class\" : \"ApplicationBiasScorer\",
             \"weight\" : 0.14999999999999999
           },
           {
             \"class\" : \"RecommendationBiasScorer\",
             \"weight\" : 0.10000000000000001
           }
         ],
         \"relevancy\" : 5,
         \"builders\" : [
           {
             \"class\" : \"ProjectsOnlyBuilder\",
             \"description\" : \"Only associations with an open project\"
           }
         ]
       },
       \"sent_at\" : null,
       \"confidence\" : 0.45000000000000001,
       \"created_at\" : \"2020-10-20T06:06:08.183082Z\",
       \"uuid\" : \"ea158cf1-f60d-4b43-89d2-da7e8713d73a\",
       \"project\" : {
         \"is_remote\" : true,
         \"host_activities\" : [

         ],
         \"start_date\" : null,
         \"is_paid\" : true,
         \"uuid\" : \"75ede467-9c60-4fce-b2ea-b6d128788218\",
         \"duration\" : \"\",
         \"description\" : \"\",
         \"type\" : \"Bespoke\",
         \"name\" : \"Marketing\",
         \"association\" : {
           \"title\" : \"\",
           \"host\" : {
             \"uuid\" : \"d5ecfbba-bd0e-4051-b285-be9f23abba2f\",
             \"full_name\" : \"Test User\",
             \"description\" : \"\",
             \"phone\" : \"\",
             \"associations\" : [
               \"c9430def-7847-42cc-b03a-298f54eb7599\"
             ],
             \"photo_thumbnails\" : null,
             \"names\" : [
               \"Test User\"
             ],
             \"twitter_handle\" : \"\",
             \"linkedin_url\" : \"\",
             \"friendly_name\" : \"\",
             \"emails\" : [
               \"barbara90@duncan.org\"
             ],
             \"instagram_handle\" : \"\",
             \"user\" : \"4d0cb9ba-c4ab-44a5-9650-934ab4858d7e\",
             \"photo\" : null,
             \"opted_into_marketing\" : false
           },
           \"location\" : {
             \"address_city\" : \"\",
             \"address_street\" : \"\",
             \"address_building\" : \"\",
             \"company\" : {
               \"name\" : \"company_1\",
               \"logo\" : null,
               \"uuid\" : \"9349b14e-5708-4db1-ac79-53c121cff344\"
             },
             \"uuid\" : \"a24383f6-0808-489e-a8a1-0ab1581529fb\",
             \"address_unit\" : \"\",
             \"address_region\" : \"\",
             \"address_country\" : \"AF\",
             \"address_postcode\" : \"\"
           }
         }
       },
       \"user\" : \"249a185a-a62b-4c93-b4b3-7169bd01f131\"
     },
     {
       \"association\" : {
         \"title\" : \"\",
         \"host\" : {
           \"uuid\" : \"2d27b641-a018-4ff6-b58e-368cb6177a2f\",
           \"full_name\" : \"Test User\",
           \"description\" : \"\",
           \"phone\" : \"\",
           \"associations\" : [
             \"4b94bb43-8886-434a-bfd8-7f433175858c\"
           ],
           \"photo_thumbnails\" : null,
           \"names\" : [
             \"Test User\"
           ],
           \"twitter_handle\" : \"\",
           \"linkedin_url\" : \"\",
           \"friendly_name\" : \"\",
           \"emails\" : [
             \"uarias@gardner-thomas.com\"
           ],
           \"instagram_handle\" : \"\",
           \"user\" : \"9a7e99e5-9b70-4e2a-9b83-a1a6f6b16359\",
           \"photo\" : null,
           \"opted_into_marketing\" : false
         },
         \"location\" : {
           \"address_city\" : \"\",
           \"address_street\" : \"\",
           \"address_building\" : \"\",
           \"company\" : {
             \"name\" : \"company_0\",
             \"logo\" : null,
             \"uuid\" : \"00f7c492-38e3-463c-8b32-ed3308c027f1\"
           },
           \"uuid\" : \"0a412311-ed35-41bb-9f38-4fabaa1a37c1\",
           \"address_unit\" : \"\",
           \"address_region\" : \"\",
           \"address_country\" : \"GB\",
           \"address_postcode\" : \"\"
         }
       },
       \"recommender\" : {
         \"scorers\" : [
           {
             \"host_period\" : 90,
             \"placement_period\" : 30,
             \"weight\" : 0.10000000000000001,
             \"class\" : \"ActivityScorer\",
             \"weights\" : {
               \"accepted\" : 0.20000000000000001,
               \"viewed\" : 0.20000000000000001,
               \"created_recently\" : 0.5,
               \"time_since_last_log_in\" : 0.10000000000000001
             }
           },
           {
             \"class\" : \"ProjectBoosterScorer\",
             \"weight\" : 0.14999999999999999
           },
           {
             \"class\" : \"ProjectUCASScorer\",
             \"weight\" : 0.5
           },
           {
             \"class\" : \"ApplicationBiasScorer\",
             \"weight\" : 0.14999999999999999
           },
           {
             \"class\" : \"RecommendationBiasScorer\",
             \"weight\" : 0.10000000000000001
           }
         ],
         \"relevancy\" : 5,
         \"builders\" : [
           {
             \"class\" : \"ProjectsOnlyBuilder\",
             \"description\" : \"Only associations with an open project\"
           }
         ]
       },
       \"sent_at\" : null,
       \"confidence\" : 0.45000000000000001,
       \"created_at\" : \"2020-10-20T06:06:08.172517Z\",
       \"uuid\" : \"d7b76f79-b7f5-4bde-a22a-1c1c449bcaed\",
       \"project\" : {
         \"is_remote\" : true,
         \"host_activities\" : [

         ],
         \"start_date\" : null,
         \"is_paid\" : true,
         \"uuid\" : \"5bde420f-4c79-4bba-92a8-a0a04b2654d8\",
         \"duration\" : \"\",
         \"description\" : \"\",
         \"type\" : \"Bespoke\",
         \"name\" : \"Marketing\",
         \"association\" : {
           \"title\" : \"\",
           \"host\" : {
             \"uuid\" : \"2d27b641-a018-4ff6-b58e-368cb6177a2f\",
             \"full_name\" : \"Test User\",
             \"description\" : \"\",
             \"phone\" : \"\",
             \"associations\" : [
               \"4b94bb43-8886-434a-bfd8-7f433175858c\"
             ],
             \"photo_thumbnails\" : null,
             \"names\" : [
               \"Test User\"
             ],
             \"twitter_handle\" : \"\",
             \"linkedin_url\" : \"\",
             \"friendly_name\" : \"\",
             \"emails\" : [
               \"uarias@gardner-thomas.com\"
             ],
             \"instagram_handle\" : \"\",
             \"user\" : \"9a7e99e5-9b70-4e2a-9b83-a1a6f6b16359\",
             \"photo\" : null,
             \"opted_into_marketing\" : false
           },
           \"location\" : {
             \"address_city\" : \"\",
             \"address_street\" : \"\",
             \"address_building\" : \"\",
             \"company\" : {
               \"name\" : \"company_0\",
               \"logo\" : null,
               \"uuid\" : \"00f7c492-38e3-463c-8b32-ed3308c027f1\"
             },
             \"uuid\" : \"0a412311-ed35-41bb-9f38-4fabaa1a37c1\",
             \"address_unit\" : \"\",
             \"address_region\" : \"\",
             \"address_country\" : \"GB\",
             \"address_postcode\" : \"\"
           }
         }
       },
       \"user\" : \"249a185a-a62b-4c93-b4b3-7169bd01f131\"
     },
     {
       \"association\" : {
         \"title\" : \"Full stack engineer\",
         \"host\" : {
           \"uuid\" : \"dfd98f13-757b-46da-b80b-1746848b0ac9\",
           \"full_name\" : \"Johnny Deuss\",
           \"description\" : \"This is the about section.\",
           \"phone\" : \"+447432655606\",
           \"associations\" : [
             \"594bb504-0ea1-46e7-ab5b-c6732b5035f0\",
             \"b484bf72-ac71-4125-8c03-c2edf00a85ad\"
           ],
           \"photo_thumbnails\" : null,
           \"names\" : [
             \"Johnny Deuss\"
           ],
           \"twitter_handle\" : \"\",
           \"linkedin_url\" : \"https://linkedin.com/in/johnny-deuss\",
           \"friendly_name\" : \"\",
           \"emails\" : [
             \"johnnydeuss@gmail.com\"
           ],
           \"instagram_handle\" : \"\",
           \"user\" : \"491f3da4-48a0-4d36-b065-4a2ad181834f\",
           \"photo\" : null,
           \"opted_into_marketing\" : false
         },
         \"location\" : {
           \"address_city\" : \"Hersham\",
           \"address_street\" : \"10 The Leys Esher Road\",
           \"address_building\" : \"\",
           \"company\" : {
             \"name\" : \"JD-Workfinder\",
             \"logo\" : null,
             \"uuid\" : \"af5b014f-c778-4718-845a-11afaaa2424e\"
           },
           \"uuid\" : \"08e01b17-22ec-4625-a594-1bf9ea2e58b3\",
           \"address_unit\" : \"\",
           \"address_region\" : \"Surrey\",
           \"address_country\" : \"GB\",
           \"address_postcode\" : \"KT12 4LP\"
         }
       },
       \"recommender\" : {
         \"scorers\" : [
           {
             \"class\" : \"ProjectBoosterScorer\",
             \"weight\" : 0.20000000000000001
           },
           {
             \"class\" : \"ProjectUCASScorer\",
             \"weight\" : 0.5
           },
           {
             \"class\" : \"RandomScorer\",
             \"weight\" : 0.14999999999999999
           },
           {
             \"class\" : \"RecommendationBiasScorer\",
             \"weight\" : 0.14999999999999999
           }
         ],
         \"relevancy\" : 5,
         \"builders\" : [
           {
             \"class\" : \"AuctionableProjectsOnlyBuilder\",
             \"description\" : \"Only associations with an auctionable project\"
           }
         ]
       },
       \"sent_at\" : \"2020-10-18T15:00:17.065732Z\",
       \"confidence\" : 0.88734093416996596,
       \"created_at\" : \"2020-10-18T15:00:16.976596Z\",
       \"uuid\" : \"a98779c1-8ee0-4c0f-98e7-b836c33111ea\",
       \"project\" : {
         \"is_remote\" : true,
         \"host_activities\" : [
           \"Comprehensive analysis and report\",
           \"Create sales battlecards\",
           \"Competitive benchmarking process\",
           \"Identify primary, secondary and tertiary competitors\"
         ],
         \"start_date\" : null,
         \"is_paid\" : true,
         \"uuid\" : \"d3b41df5-7b30-4e48-b7dc-ca4007a2c012\",
         \"duration\" : \"\",
         \"description\" : \"We’re looking for students to complete a short work placement focused on generating creative digital marketing content. You’ll be responsible for analysing the performance of previous content, understanding the target market’s motivations, and creating a new content and delivery calendar to meet our needs. Working alongside the marketing function of the business you’ll have the chance to hone your skills and learn more about working in digital marketing whilst adding real value to the business.\",
         \"type\" : \"Creative Digital Marketing\",
         \"name\" : \"Creative Digital Marketing\",
         \"association\" : {
           \"title\" : \"Full stack engineer\",
           \"host\" : {
             \"uuid\" : \"dfd98f13-757b-46da-b80b-1746848b0ac9\",
             \"full_name\" : \"Johnny Deuss\",
             \"description\" : \"This is the about section.\",
             \"phone\" : \"+447432655606\",
             \"associations\" : [
               \"594bb504-0ea1-46e7-ab5b-c6732b5035f0\",
               \"b484bf72-ac71-4125-8c03-c2edf00a85ad\"
             ],
             \"photo_thumbnails\" : null,
             \"names\" : [
               \"Johnny Deuss\"
             ],
             \"twitter_handle\" : \"\",
             \"linkedin_url\" : \"https://linkedin.com/in/johnny-deuss\",
             \"friendly_name\" : \"\",
             \"emails\" : [
               \"johnnydeuss@gmail.com\"
             ],
             \"instagram_handle\" : \"\",
             \"user\" : \"491f3da4-48a0-4d36-b065-4a2ad181834f\",
             \"photo\" : null,
             \"opted_into_marketing\" : false
           },
           \"location\" : {
             \"address_city\" : \"Hersham\",
             \"address_street\" : \"10 The Leys Esher Road\",
             \"address_building\" : \"\",
             \"company\" : {
               \"name\" : \"JD-Workfinder\",
               \"logo\" : null,
               \"uuid\" : \"af5b014f-c778-4718-845a-11afaaa2424e\"
             },
             \"uuid\" : \"08e01b17-22ec-4625-a594-1bf9ea2e58b3\",
             \"address_unit\" : \"\",
             \"address_region\" : \"Surrey\",
             \"address_country\" : \"GB\",
             \"address_postcode\" : \"KT12 4LP\"
           }
         }
       },
       \"user\" : \"249a185a-a62b-4c93-b4b3-7169bd01f131\"
     },
     {
       \"association\" : {
         \"title\" : \"Chief Technology Officer at Workfinder\",
         \"host\" : {
           \"uuid\" : \"84d0a788-eede-42cd-a07b-8b3691ee8765\",
           \"full_name\" : \"Feroze Rub\",
           \"description\" : \"An entrepreneurial Chief Technical Officer with a track record gained working for high technology start-ups, large digital agencies and Blue Chip corporations. Leading engineering, product and growth teams to develop innovative software solutions & bespoke web technologies to deliver outstanding digital solutions. \n\n'It has to be better' and for me this often means designing elegant solutions. Elegant because they are cleverly simple both in design and to use.\n\nInspired in delivering the 'internet of things' through M2M solutions and innovative digital solutions in an adaptive, responsive landscape.\",
           \"phone\" : \"+447956842875\",
           \"associations\" : [
             \"98168264-3210-4440-a576-15100d5f6dfe\",
             \"5461624b-3a89-40e8-bbb7-45098a4d917e\",
             \"839c709c-1c14-4636-bcc2-86f5b4b2b619\",
             \"d6580c45-db16-499d-86e2-a89b5190ac2e\"
           ],
           \"photo_thumbnails\" : {
             \"m\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/84d0a788-eede-42cd-a07b-8b3691ee8765.jpg.512x512_q85.jpg\",
             \"s-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/84d0a788-eede-42cd-a07b-8b3691ee8765.jpg.256x256_q85_crop.jpg\",
             \"s\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/84d0a788-eede-42cd-a07b-8b3691ee8765.jpg.256x256_q85.jpg\",
             \"l-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/84d0a788-eede-42cd-a07b-8b3691ee8765.jpg.1024x1024_q85_crop.jpg\",
             \"l\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/84d0a788-eede-42cd-a07b-8b3691ee8765.jpg.1024x1024_q85.jpg\",
             \"m-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/84d0a788-eede-42cd-a07b-8b3691ee8765.jpg.512x512_q85_crop.jpg\"
           },
           \"names\" : [
             \"Feroze Rub\"
           ],
           \"twitter_handle\" : \"\",
           \"linkedin_url\" : \"https://linkedin.com/in/feroze-rub-8424111\",
           \"friendly_name\" : \"\",
           \"emails\" : [
             \"feroze@taridigital.com\"
           ],
           \"instagram_handle\" : \"\",
           \"user\" : \"2948012f-2328-4f41-a560-fea1a3e23052\",
           \"photo\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/hosts/derived/84d0a788-eede-42cd-a07b-8b3691ee8765.jpg\",
           \"opted_into_marketing\" : false
         },
         \"location\" : {
           \"address_city\" : \"Harrow\",
           \"address_street\" : \"90 Hindes Road\",
           \"address_building\" : \"\",
           \"company\" : {
             \"name\" : \"Tari digital\",
             \"logo\" : null,
             \"uuid\" : \"11337b90-dc88-4f91-8c18-d940f97b320e\"
           },
           \"uuid\" : \"34cfd916-fddd-4172-919f-5e4e0e5bc6a3\",
           \"address_unit\" : \"\",
           \"address_region\" : \"Greater London\",
           \"address_country\" : \"GB\",
           \"address_postcode\" : \"HA1 1RP\"
         }
       },
       \"recommender\" : {
         \"scorers\" : [
           {
             \"class\" : \"ProjectBoosterScorer\",
             \"weight\" : 0.20000000000000001
           },
           {
             \"class\" : \"ProjectUCASScorer\",
             \"weight\" : 0.5
           },
           {
             \"class\" : \"RandomScorer\",
             \"weight\" : 0.14999999999999999
           },
           {
             \"class\" : \"RecommendationBiasScorer\",
             \"weight\" : 0.14999999999999999
           }
         ],
         \"relevancy\" : 5,
         \"builders\" : [
           {
             \"class\" : \"AuctionableProjectsOnlyBuilder\",
             \"description\" : \"Only associations with an auctionable project\"
           }
         ]
       },
       \"sent_at\" : \"2020-10-18T15:00:17.123188Z\",
       \"confidence\" : 0.80676757350876505,
       \"created_at\" : \"2020-10-18T15:00:16.964773Z\",
       \"uuid\" : \"10afbe32-a369-463f-8323-176ea990c3ea\",
       \"project\" : {
         \"is_remote\" : true,
         \"host_activities\" : [
           \"Comprehensive analysis and report\",
           \"Create sales battlecards\",
           \"Competitive benchmarking process\",
           \"Identify primary, secondary and tertiary competitors\"
         ],
         \"start_date\" : null,
         \"is_paid\" : true,
         \"uuid\" : \"89ea965a-defc-42c3-9864-824a59f33847\",
         \"duration\" : \"\",
         \"description\" : \"We’re looking for students to complete a short work placement focused on generating creative digital marketing content. You’ll be responsible for analysing the performance of previous content, understanding the target market’s motivations, and creating a new content and delivery calendar to meet our needs. Working alongside the marketing function of the business you’ll have the chance to hone your skills and learn more about working in digital marketing whilst adding real value to the business.\",
         \"type\" : \"Creative Digital Marketing\",
         \"name\" : \"Creative Digital Marketing\",
         \"association\" : {
           \"title\" : \"Chief Technology Officer at Workfinder\",
           \"host\" : {
             \"uuid\" : \"84d0a788-eede-42cd-a07b-8b3691ee8765\",
             \"full_name\" : \"Feroze Rub\",
             \"description\" : \"An entrepreneurial Chief Technical Officer with a track record gained working for high technology start-ups, large digital agencies and Blue Chip corporations. Leading engineering, product and growth teams to develop innovative software solutions & bespoke web technologies to deliver outstanding digital solutions. \n\n'It has to be better' and for me this often means designing elegant solutions. Elegant because they are cleverly simple both in design and to use.\n\nInspired in delivering the 'internet of things' through M2M solutions and innovative digital solutions in an adaptive, responsive landscape.\",
             \"phone\" : \"+447956842875\",
             \"associations\" : [
               \"98168264-3210-4440-a576-15100d5f6dfe\",
               \"5461624b-3a89-40e8-bbb7-45098a4d917e\",
               \"839c709c-1c14-4636-bcc2-86f5b4b2b619\",
               \"d6580c45-db16-499d-86e2-a89b5190ac2e\"
             ],
             \"photo_thumbnails\" : {
               \"m\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/84d0a788-eede-42cd-a07b-8b3691ee8765.jpg.512x512_q85.jpg\",
               \"s-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/84d0a788-eede-42cd-a07b-8b3691ee8765.jpg.256x256_q85_crop.jpg\",
               \"s\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/84d0a788-eede-42cd-a07b-8b3691ee8765.jpg.256x256_q85.jpg\",
               \"l-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/84d0a788-eede-42cd-a07b-8b3691ee8765.jpg.1024x1024_q85_crop.jpg\",
               \"l\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/84d0a788-eede-42cd-a07b-8b3691ee8765.jpg.1024x1024_q85.jpg\",
               \"m-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/84d0a788-eede-42cd-a07b-8b3691ee8765.jpg.512x512_q85_crop.jpg\"
             },
             \"names\" : [
               \"Feroze Rub\"
             ],
             \"twitter_handle\" : \"\",
             \"linkedin_url\" : \"https://linkedin.com/in/feroze-rub-8424111\",
             \"friendly_name\" : \"\",
             \"emails\" : [
               \"feroze@taridigital.com\"
             ],
             \"instagram_handle\" : \"\",
             \"user\" : \"2948012f-2328-4f41-a560-fea1a3e23052\",
             \"photo\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/hosts/derived/84d0a788-eede-42cd-a07b-8b3691ee8765.jpg\",
             \"opted_into_marketing\" : false
           },
           \"location\" : {
             \"address_city\" : \"Harrow\",
             \"address_street\" : \"90 Hindes Road\",
             \"address_building\" : \"\",
             \"company\" : {
               \"name\" : \"Tari digital\",
               \"logo\" : null,
               \"uuid\" : \"11337b90-dc88-4f91-8c18-d940f97b320e\"
             },
             \"uuid\" : \"34cfd916-fddd-4172-919f-5e4e0e5bc6a3\",
             \"address_unit\" : \"\",
             \"address_region\" : \"Greater London\",
             \"address_country\" : \"GB\",
             \"address_postcode\" : \"HA1 1RP\"
           }
         }
       },
       \"user\" : \"249a185a-a62b-4c93-b4b3-7169bd01f131\"
     },
     {
       \"association\" : {
         \"title\" : \"Chief Product Officer at Workfinder | D&I Speaker | Coach\",
         \"host\" : {
           \"uuid\" : \"bd4c891f-1e08-4a66-b519-3dd33c425370\",
           \"full_name\" : \"Anusha Nirmalananthan\",
           \"description\" : \"Over 15 years experience as a Technology Leader at start-ups and global tech companies. Experienced people manager developing cross-functional teams, across complex organisations to drive delivery, commercial impact and innovation from within. Broad experience with consumer-facing UX products, Data/AI and B2B platforms.\n\nPublic speaker on diversity and inclusion in the tech industry. Advisor and mentor for individuals and SMEs. BA in Computer Science (Queens’ College, Cambridge University), Postgraduate Diploma in Marketing (CIM) and Diploma in Counselling (Mary Ward).\n\nSpecialties: product management, user experience, design research, hiring and developing great teams\",
           \"phone\" : \"\",
           \"associations\" : [
             \"8011c719-dc77-4ca1-94db-0cc7502b508f\"
           ],
           \"photo_thumbnails\" : {
             \"m\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/bd4c891f-1e08-4a66-b519-3dd33c425370.jpg.512x512_q85.jpg\",
             \"s-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/bd4c891f-1e08-4a66-b519-3dd33c425370.jpg.256x256_q85_crop.jpg\",
             \"s\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/bd4c891f-1e08-4a66-b519-3dd33c425370.jpg.256x256_q85.jpg\",
             \"l-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/bd4c891f-1e08-4a66-b519-3dd33c425370.jpg.1024x1024_q85_crop.jpg\",
             \"l\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/bd4c891f-1e08-4a66-b519-3dd33c425370.jpg.1024x1024_q85.jpg\",
             \"m-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/bd4c891f-1e08-4a66-b519-3dd33c425370.jpg.512x512_q85_crop.jpg\"
           },
           \"names\" : [
             \"Anusha Nirmalananthan\"
           ],
           \"twitter_handle\" : \"\",
           \"linkedin_url\" : \"https://linkedin.com/in/anushan\",
           \"friendly_name\" : \"\",
           \"emails\" : [
             \"anusha.n+4@workfinder.com\",
             \"anushan@gmail.com\"
           ],
           \"instagram_handle\" : \"\",
           \"user\" : \"d83dd861-9a1e-4f2f-9999-4f81e2280c11\",
           \"photo\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/hosts/derived/bd4c891f-1e08-4a66-b519-3dd33c425370.jpg\",
           \"opted_into_marketing\" : true
         },
         \"location\" : {
           \"address_city\" : \"London\",
           \"address_street\" : \"27 Old Gloucester Street\",
           \"address_building\" : \"\",
           \"company\" : {
             \"name\" : \"Workfinder\",
             \"logo\" : null,
             \"uuid\" : \"7a7f03cc-dc4f-4b72-b2ba-f72501cbeef0\"
           },
           \"uuid\" : \"cde831a1-d2ed-4602-8e2f-66a7e3d674d6\",
           \"address_unit\" : \"\",
           \"address_region\" : \"\",
           \"address_country\" : \"GB\",
           \"address_postcode\" : \"WC1N 3AF\"
         }
       },
       \"recommender\" : {
         \"scorers\" : [
           {
             \"class\" : \"DistanceScorer\",
             \"weight\" : 0.10000000000000001
           },
           {
             \"host_period\" : 90,
             \"placement_period\" : 30,
             \"weight\" : 0.20000000000000001,
             \"class\" : \"ActivityScorer\",
             \"weights\" : {
               \"accepted\" : 0.20000000000000001,
               \"viewed\" : 0.20000000000000001,
               \"created_recently\" : 0.5,
               \"time_since_last_log_in\" : 0.10000000000000001
             }
           },
           {
             \"class\" : \"HostProjectUCASScorer\",
             \"weight\" : 0
           },
           {
             \"class\" : \"ProjectBoosterScorer\",
             \"weight\" : 0.25
           },
           {
             \"class\" : \"SubjectTagScorer\",
             \"weight\" : 0
           },
           {
             \"class\" : \"ProjectUCASScorer\",
             \"weight\" : 0.45000000000000001
           }
         ],
         \"relevancy\" : 5,
         \"builders\" : [
           {
             \"class\" : \"ProjectsOnlyBuilder\",
             \"description\" : \"Only associations with an open project\"
           },
           {
             \"max_radius\" : 10,
             \"max_companies\" : 300,
             \"class\" : \"GeographicBuilder\",
             \"description\" : \"Nearest 300 companies within 10 km radius\"
           }
         ]
       },
       \"sent_at\" : \"2020-10-19T06:06:06.687108Z\",
       \"confidence\" : 0.70808142188009404,
       \"created_at\" : \"2020-10-16T06:06:09.533539Z\",
       \"uuid\" : \"655eeb05-d584-4b44-ae31-1617dcc334d9\",
       \"project\" : {
         \"is_remote\" : true,
         \"host_activities\" : [
           \"UX analysis of current product\",
           \"Test scenario of specific feature\",
           \"Proposal of UX improvements\",
           \"Concept design and wireframing\"
         ],
         \"start_date\" : null,
         \"is_paid\" : true,
         \"uuid\" : \"7da007c0-3afb-43f6-a7d0-dd77ff84cc0c\",
         \"duration\" : \"\",
         \"description\" : \"We’re looking for students to complete a short work placement focused on UX testing and analysis. You’ll be responsible for assessing the UI and overall UX of the product, running through the entire journey. Documenting as you go, you’ll be able to deliver recommendations and suggestions for improvements. Working alongside the tech and product side of the business you’ll have the chance to hone your skills and learn more about working on user-centric design whilst adding real value to the business.\",
         \"type\" : \"UX Testing and Analysis\",
         \"name\" : \"UX Testing and Analysis\",
         \"association\" : {
           \"title\" : \"Chief Product Officer at Workfinder | D&I Speaker | Coach\",
           \"host\" : {
             \"uuid\" : \"bd4c891f-1e08-4a66-b519-3dd33c425370\",
             \"full_name\" : \"Anusha Nirmalananthan\",
             \"description\" : \"Over 15 years experience as a Technology Leader at start-ups and global tech companies. Experienced people manager developing cross-functional teams, across complex organisations to drive delivery, commercial impact and innovation from within. Broad experience with consumer-facing UX products, Data/AI and B2B platforms.\n\nPublic speaker on diversity and inclusion in the tech industry. Advisor and mentor for individuals and SMEs. BA in Computer Science (Queens’ College, Cambridge University), Postgraduate Diploma in Marketing (CIM) and Diploma in Counselling (Mary Ward).\n\nSpecialties: product management, user experience, design research, hiring and developing great teams\",
             \"phone\" : \"\",
             \"associations\" : [
               \"8011c719-dc77-4ca1-94db-0cc7502b508f\"
             ],
             \"photo_thumbnails\" : {
               \"m\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/bd4c891f-1e08-4a66-b519-3dd33c425370.jpg.512x512_q85.jpg\",
               \"s-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/bd4c891f-1e08-4a66-b519-3dd33c425370.jpg.256x256_q85_crop.jpg\",
               \"s\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/bd4c891f-1e08-4a66-b519-3dd33c425370.jpg.256x256_q85.jpg\",
               \"l-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/bd4c891f-1e08-4a66-b519-3dd33c425370.jpg.1024x1024_q85_crop.jpg\",
               \"l\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/bd4c891f-1e08-4a66-b519-3dd33c425370.jpg.1024x1024_q85.jpg\",
               \"m-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/bd4c891f-1e08-4a66-b519-3dd33c425370.jpg.512x512_q85_crop.jpg\"
             },
             \"names\" : [
               \"Anusha Nirmalananthan\"
             ],
             \"twitter_handle\" : \"\",
             \"linkedin_url\" : \"https://linkedin.com/in/anushan\",
             \"friendly_name\" : \"\",
             \"emails\" : [
               \"anusha.n+4@workfinder.com\",
               \"anushan@gmail.com\"
             ],
             \"instagram_handle\" : \"\",
             \"user\" : \"d83dd861-9a1e-4f2f-9999-4f81e2280c11\",
             \"photo\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/hosts/derived/bd4c891f-1e08-4a66-b519-3dd33c425370.jpg\",
             \"opted_into_marketing\" : true
           },
           \"location\" : {
             \"address_city\" : \"London\",
             \"address_street\" : \"27 Old Gloucester Street\",
             \"address_building\" : \"\",
             \"company\" : {
               \"name\" : \"Workfinder\",
               \"logo\" : null,
               \"uuid\" : \"7a7f03cc-dc4f-4b72-b2ba-f72501cbeef0\"
             },
             \"uuid\" : \"cde831a1-d2ed-4602-8e2f-66a7e3d674d6\",
             \"address_unit\" : \"\",
             \"address_region\" : \"\",
             \"address_country\" : \"GB\",
             \"address_postcode\" : \"WC1N 3AF\"
           }
         }
       },
       \"user\" : \"249a185a-a62b-4c93-b4b3-7169bd01f131\"
     },
     {
       \"association\" : {
         \"title\" : \"Head of Programme Delivery\",
         \"host\" : {
           \"uuid\" : \"8f9605f7-52e5-4659-a469-9769a42a64f8\",
           \"full_name\" : \"Skye Willis\",
           \"description\" : \"A proven, and fully qualified professional with a wealth of experiences across different industries with a desire to support young people to be the best they can be.\n\nDedicated, flexible and passionate. Exceptional technical knowledge, creative approach to problem-solving, ability to manage multiple projects concurrently, excellent communication skills and a strong determination to always exceed expectations.\",
           \"phone\" : \"02084197915\",
           \"associations\" : [
             \"23386d60-3502-403c-81ef-97bf1c74da0e\"
           ],
           \"photo_thumbnails\" : {
             \"m\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/8f9605f7-52e5-4659-a469-9769a42a64f8.jpg.512x512_q85.jpg\",
             \"s-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/8f9605f7-52e5-4659-a469-9769a42a64f8.jpg.256x256_q85_crop.jpg\",
             \"s\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/8f9605f7-52e5-4659-a469-9769a42a64f8.jpg.256x256_q85.jpg\",
             \"l-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/8f9605f7-52e5-4659-a469-9769a42a64f8.jpg.1024x1024_q85_crop.jpg\",
             \"l\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/8f9605f7-52e5-4659-a469-9769a42a64f8.jpg.1024x1024_q85.jpg\",
             \"m-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/8f9605f7-52e5-4659-a469-9769a42a64f8.jpg.512x512_q85_crop.jpg\"
           },
           \"names\" : [
             \"Skye Willis\"
           ],
           \"twitter_handle\" : \"\",
           \"linkedin_url\" : \"https://linkedin.com/in/skyewillis\",
           \"friendly_name\" : \"\",
           \"emails\" : [
             \"skye.willis@workfinder.com\",
             \"skyewillis2019@gmail.com\"
           ],
           \"instagram_handle\" : \"\",
           \"user\" : \"6b850db3-0736-47f8-b907-e8739ab4c322\",
           \"photo\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/hosts/derived/8f9605f7-52e5-4659-a469-9769a42a64f8.jpg\",
           \"opted_into_marketing\" : false
         },
         \"location\" : {
           \"address_city\" : \"London\",
           \"address_street\" : \"27 Old Gloucester Street\",
           \"address_building\" : \"\",
           \"company\" : {
             \"name\" : \"Workfinder\",
             \"logo\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/companies/derived/e4136dc1-22f7-4025-8389-081c9480c322.png\",
             \"uuid\" : \"e4136dc1-22f7-4025-8389-081c9480c322\"
           },
           \"uuid\" : \"d8393335-10ce-433e-96a4-c1c8b0a1b2ba\",
           \"address_unit\" : \"\",
           \"address_region\" : \"\",
           \"address_country\" : \"GB\",
           \"address_postcode\" : \"WC1N 3AX\"
         }
       },
       \"recommender\" : {
         \"scorers\" : [
           {
             \"class\" : \"DistanceScorer\",
             \"weight\" : 0.10000000000000001
           },
           {
             \"host_period\" : 90,
             \"placement_period\" : 30,
             \"weight\" : 0.20000000000000001,
             \"class\" : \"ActivityScorer\",
             \"weights\" : {
               \"accepted\" : 0.20000000000000001,
               \"viewed\" : 0.20000000000000001,
               \"created_recently\" : 0.5,
               \"time_since_last_log_in\" : 0.10000000000000001
             }
           },
           {
             \"class\" : \"HostProjectUCASScorer\",
             \"weight\" : 0
           },
           {
             \"class\" : \"ProjectBoosterScorer\",
             \"weight\" : 0.25
           },
           {
             \"class\" : \"SubjectTagScorer\",
             \"weight\" : 0
           },
           {
             \"class\" : \"ProjectUCASScorer\",
             \"weight\" : 0.45000000000000001
           }
         ],
         \"relevancy\" : 5,
         \"builders\" : [
           {
             \"class\" : \"ProjectsOnlyBuilder\",
             \"description\" : \"Only associations with an open project\"
           },
           {
             \"max_radius\" : 10,
             \"max_companies\" : 300,
             \"class\" : \"GeographicBuilder\",
             \"description\" : \"Nearest 300 companies within 10 km radius\"
           }
         ]
       },
       \"sent_at\" : \"2020-10-18T06:06:08.323920Z\",
       \"confidence\" : 0.66397992351801505,
       \"created_at\" : \"2020-10-16T06:06:09.415750Z\",
       \"uuid\" : \"298a5d09-a347-4857-bd71-d16e2167820d\",
       \"project\" : {
         \"is_remote\" : true,
         \"host_activities\" : [
           \"UX analysis of current product\",
           \"Test scenario of specific feature\",
           \"Proposal of UX improvements\",
           \"Concept design and wireframing\"
         ],
         \"start_date\" : null,
         \"is_paid\" : true,
         \"uuid\" : \"abaccddc-7ba8-448d-a466-974aef0bac75\",
         \"duration\" : \"\",
         \"description\" : \"We’re looking for students to complete a short work placement focused on UX testing and analysis. You’ll be responsible for assessing the UI and overall UX of the product, running through the entire journey. Documenting as you go, you’ll be able to deliver recommendations and suggestions for improvements. Working alongside the tech and product side of the business you’ll have the chance to hone your skills and learn more about working on user-centric design whilst adding real value to the business.\",
         \"type\" : \"UX Testing and Analysis\",
         \"name\" : \"UX Testing and Analysis\",
         \"association\" : {
           \"title\" : \"Head of Programme Delivery\",
           \"host\" : {
             \"uuid\" : \"8f9605f7-52e5-4659-a469-9769a42a64f8\",
             \"full_name\" : \"Skye Willis\",
             \"description\" : \"A proven, and fully qualified professional with a wealth of experiences across different industries with a desire to support young people to be the best they can be.\n\nDedicated, flexible and passionate. Exceptional technical knowledge, creative approach to problem-solving, ability to manage multiple projects concurrently, excellent communication skills and a strong determination to always exceed expectations.\",
             \"phone\" : \"02084197915\",
             \"associations\" : [
               \"23386d60-3502-403c-81ef-97bf1c74da0e\"
             ],
             \"photo_thumbnails\" : {
               \"m\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/8f9605f7-52e5-4659-a469-9769a42a64f8.jpg.512x512_q85.jpg\",
               \"s-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/8f9605f7-52e5-4659-a469-9769a42a64f8.jpg.256x256_q85_crop.jpg\",
               \"s\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/8f9605f7-52e5-4659-a469-9769a42a64f8.jpg.256x256_q85.jpg\",
               \"l-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/8f9605f7-52e5-4659-a469-9769a42a64f8.jpg.1024x1024_q85_crop.jpg\",
               \"l\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/8f9605f7-52e5-4659-a469-9769a42a64f8.jpg.1024x1024_q85.jpg\",
               \"m-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/8f9605f7-52e5-4659-a469-9769a42a64f8.jpg.512x512_q85_crop.jpg\"
             },
             \"names\" : [
               \"Skye Willis\"
             ],
             \"twitter_handle\" : \"\",
             \"linkedin_url\" : \"https://linkedin.com/in/skyewillis\",
             \"friendly_name\" : \"\",
             \"emails\" : [
               \"skye.willis@workfinder.com\",
               \"skyewillis2019@gmail.com\"
             ],
             \"instagram_handle\" : \"\",
             \"user\" : \"6b850db3-0736-47f8-b907-e8739ab4c322\",
             \"photo\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/hosts/derived/8f9605f7-52e5-4659-a469-9769a42a64f8.jpg\",
             \"opted_into_marketing\" : false
           },
           \"location\" : {
             \"address_city\" : \"London\",
             \"address_street\" : \"27 Old Gloucester Street\",
             \"address_building\" : \"\",
             \"company\" : {
               \"name\" : \"Workfinder\",
               \"logo\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/companies/derived/e4136dc1-22f7-4025-8389-081c9480c322.png\",
               \"uuid\" : \"e4136dc1-22f7-4025-8389-081c9480c322\"
             },
             \"uuid\" : \"d8393335-10ce-433e-96a4-c1c8b0a1b2ba\",
             \"address_unit\" : \"\",
             \"address_region\" : \"\",
             \"address_country\" : \"GB\",
             \"address_postcode\" : \"WC1N 3AX\"
           }
         }
       },
       \"user\" : \"249a185a-a62b-4c93-b4b3-7169bd01f131\"
     },
     {
       \"association\" : {
         \"title\" : \"Product Design (UX/UI/Digital Design)\",
         \"host\" : {
           \"uuid\" : \"fddc9d89-b379-467c-9eac-a6d206c49c49\",
           \"full_name\" : \"Arvind Lall\",
           \"description\" : \"I am a multi-disciplinary designer, who enjoys working on projects in the fashion and lifestyle industry. Although classically trained in graphic design my career focus has been in the digital art direction and creative strategy.  \n\nPrevious work and experimentation have encapsulated an enthusiastic approach to creative direction. This includes branding, editorial layout, styling and digital storytelling. \n\nWorking for some of the world's leading fashion brands including Burberry, Mulberry, Alexander McQueen and Mary Katrantzou as well as extensive experience in agencies like Wednesday has allowed me to be at forefront of innovative, defining and boundary breaking projects.\",
           \"phone\" : \"07947728711\",
           \"associations\" : [
             \"e27dd6f0-ce70-47e1-9a34-d45c95ba2ddf\"
           ],
           \"photo_thumbnails\" : {
             \"m\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/fddc9d89-b379-467c-9eac-a6d206c49c49.jpg.512x512_q85.jpg\",
             \"s-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/fddc9d89-b379-467c-9eac-a6d206c49c49.jpg.256x256_q85_crop.jpg\",
             \"s\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/fddc9d89-b379-467c-9eac-a6d206c49c49.jpg.256x256_q85.jpg\",
             \"l-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/fddc9d89-b379-467c-9eac-a6d206c49c49.jpg.1024x1024_q85_crop.jpg\",
             \"l\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/fddc9d89-b379-467c-9eac-a6d206c49c49.jpg.1024x1024_q85.jpg\",
             \"m-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/fddc9d89-b379-467c-9eac-a6d206c49c49.jpg.512x512_q85_crop.jpg\"
           },
           \"names\" : [
             \"Arvind Lall\"
           ],
           \"twitter_handle\" : \"\",
           \"linkedin_url\" : \"https://linkedin.com/in/arvindlall\",
           \"friendly_name\" : \"\",
           \"emails\" : [
             \"arvind.lall@wunderman.com\",
             \"Arvind.Lall.Studio@gmail.com\"
           ],
           \"instagram_handle\" : \"\",
           \"user\" : \"5b0731c6-cc44-466d-a34c-a72fc1d994ea\",
           \"photo\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/hosts/derived/fddc9d89-b379-467c-9eac-a6d206c49c49.jpg\",
           \"opted_into_marketing\" : false
         },
         \"location\" : {
           \"address_city\" : \"London\",
           \"address_street\" : \"13 Trinity Church Square Southwark\",
           \"address_building\" : \"\",
           \"company\" : {
             \"name\" : \"Workfonder\",
             \"logo\" : null,
             \"uuid\" : \"e0d2bf44-a1aa-4368-b876-a12c6be714ea\"
           },
           \"uuid\" : \"0a110f33-ac8e-413c-a6da-e309d9faf9ae\",
           \"address_unit\" : \"\",
           \"address_region\" : \"\",
           \"address_country\" : \"GB\",
           \"address_postcode\" : \"SE1 4HU\"
         }
       },
       \"recommender\" : {
         \"scorers\" : [
           {
             \"class\" : \"DistanceScorer\",
             \"weight\" : 0.10000000000000001
           },
           {
             \"host_period\" : 90,
             \"placement_period\" : 30,
             \"weight\" : 0.20000000000000001,
             \"class\" : \"ActivityScorer\",
             \"weights\" : {
               \"accepted\" : 0.20000000000000001,
               \"viewed\" : 0.20000000000000001,
               \"created_recently\" : 0.5,
               \"time_since_last_log_in\" : 0.10000000000000001
             }
           },
           {
             \"class\" : \"HostProjectUCASScorer\",
             \"weight\" : 0
           },
           {
             \"class\" : \"ProjectBoosterScorer\",
             \"weight\" : 0.25
           },
           {
             \"class\" : \"SubjectTagScorer\",
             \"weight\" : 0
           },
           {
             \"class\" : \"ProjectUCASScorer\",
             \"weight\" : 0.45000000000000001
           }
         ],
         \"relevancy\" : 5,
         \"builders\" : [
           {
             \"class\" : \"ProjectsOnlyBuilder\",
             \"description\" : \"Only associations with an open project\"
           },
           {
             \"max_radius\" : 10,
             \"max_companies\" : 300,
             \"class\" : \"GeographicBuilder\",
             \"description\" : \"Nearest 300 companies within 10 km radius\"
           }
         ]
       },
       \"sent_at\" : \"2020-10-17T06:06:17.884441Z\",
       \"confidence\" : 0.67092641845523504,
       \"created_at\" : \"2020-10-16T06:06:09.282170Z\",
       \"uuid\" : \"d0c35035-955c-4123-92e2-fa8bffb99818\",
       \"project\" : {
         \"is_remote\" : true,
         \"host_activities\" : [
           \"UX analysis of current product\",
           \"Test scenario of specific feature\",
           \"Proposal of UX improvements\",
           \"Concept design and wireframing\"
         ],
         \"start_date\" : null,
         \"is_paid\" : true,
         \"uuid\" : \"9c8edabc-640c-46a5-81fc-93da5d819918\",
         \"duration\" : \"\",
         \"description\" : \"We’re looking for students to complete a short work placement focused on UX testing and analysis. You’ll be responsible for assessing the UI and overall UX of the product, running through the entire journey. Documenting as you go, you’ll be able to deliver recommendations and suggestions for improvements. Working alongside the tech and product side of the business you’ll have the chance to hone your skills and learn more about working on user-centric design whilst adding real value to the business.\",
         \"type\" : \"UX Testing and Analysis\",
         \"name\" : \"UX Testing and Analysis\",
         \"association\" : {
           \"title\" : \"Product Design (UX/UI/Digital Design)\",
           \"host\" : {
             \"uuid\" : \"fddc9d89-b379-467c-9eac-a6d206c49c49\",
             \"full_name\" : \"Arvind Lall\",
             \"description\" : \"I am a multi-disciplinary designer, who enjoys working on projects in the fashion and lifestyle industry. Although classically trained in graphic design my career focus has been in the digital art direction and creative strategy.  \n\nPrevious work and experimentation have encapsulated an enthusiastic approach to creative direction. This includes branding, editorial layout, styling and digital storytelling. \n\nWorking for some of the world's leading fashion brands including Burberry, Mulberry, Alexander McQueen and Mary Katrantzou as well as extensive experience in agencies like Wednesday has allowed me to be at forefront of innovative, defining and boundary breaking projects.\",
             \"phone\" : \"07947728711\",
             \"associations\" : [
               \"e27dd6f0-ce70-47e1-9a34-d45c95ba2ddf\"
             ],
             \"photo_thumbnails\" : {
               \"m\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/fddc9d89-b379-467c-9eac-a6d206c49c49.jpg.512x512_q85.jpg\",
               \"s-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/fddc9d89-b379-467c-9eac-a6d206c49c49.jpg.256x256_q85_crop.jpg\",
               \"s\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/fddc9d89-b379-467c-9eac-a6d206c49c49.jpg.256x256_q85.jpg\",
               \"l-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/fddc9d89-b379-467c-9eac-a6d206c49c49.jpg.1024x1024_q85_crop.jpg\",
               \"l\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/fddc9d89-b379-467c-9eac-a6d206c49c49.jpg.1024x1024_q85.jpg\",
               \"m-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/fddc9d89-b379-467c-9eac-a6d206c49c49.jpg.512x512_q85_crop.jpg\"
             },
             \"names\" : [
               \"Arvind Lall\"
             ],
             \"twitter_handle\" : \"\",
             \"linkedin_url\" : \"https://linkedin.com/in/arvindlall\",
             \"friendly_name\" : \"\",
             \"emails\" : [
               \"arvind.lall@wunderman.com\",
               \"Arvind.Lall.Studio@gmail.com\"
             ],
             \"instagram_handle\" : \"\",
             \"user\" : \"5b0731c6-cc44-466d-a34c-a72fc1d994ea\",
             \"photo\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/hosts/derived/fddc9d89-b379-467c-9eac-a6d206c49c49.jpg\",
             \"opted_into_marketing\" : false
           },
           \"location\" : {
             \"address_city\" : \"London\",
             \"address_street\" : \"13 Trinity Church Square Southwark\",
             \"address_building\" : \"\",
             \"company\" : {
               \"name\" : \"Workfonder\",
               \"logo\" : null,
               \"uuid\" : \"e0d2bf44-a1aa-4368-b876-a12c6be714ea\"
             },
             \"uuid\" : \"0a110f33-ac8e-413c-a6da-e309d9faf9ae\",
             \"address_unit\" : \"\",
             \"address_region\" : \"\",
             \"address_country\" : \"GB\",
             \"address_postcode\" : \"SE1 4HU\"
           }
         }
       },
       \"user\" : \"249a185a-a62b-4c93-b4b3-7169bd01f131\"
     },
     {
       \"association\" : {
         \"title\" : \"Application Testing Intern at Workfinder\",
         \"host\" : {
           \"uuid\" : \"6696ae98-9721-452f-bed4-77cbe28bf266\",
           \"full_name\" : \"Shiven Senthilkumar\",
           \"description\" : \"\",
           \"phone\" : \"07953396514\",
           \"associations\" : [
             \"a6057bf5-379d-43f3-8616-c5704570fab9\"
           ],
           \"photo_thumbnails\" : {
             \"m\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/6696ae98-9721-452f-bed4-77cbe28bf266.jpg.512x512_q85.jpg\",
             \"s-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/6696ae98-9721-452f-bed4-77cbe28bf266.jpg.256x256_q85_crop.jpg\",
             \"s\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/6696ae98-9721-452f-bed4-77cbe28bf266.jpg.256x256_q85.jpg\",
             \"l-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/6696ae98-9721-452f-bed4-77cbe28bf266.jpg.1024x1024_q85_crop.jpg\",
             \"l\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/6696ae98-9721-452f-bed4-77cbe28bf266.jpg.1024x1024_q85.jpg\",
             \"m-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/6696ae98-9721-452f-bed4-77cbe28bf266.jpg.512x512_q85_crop.jpg\"
           },
           \"names\" : [
             \"Shiven Senthilkumar\"
           ],
           \"twitter_handle\" : \"\",
           \"linkedin_url\" : \"https://linkedin.com/in/shiven-s\",
           \"friendly_name\" : \"\",
           \"emails\" : [
             \"shiven.senthilkumar+testinghost@workfinder.com\",
             \"shivens@live.co.uk\"
           ],
           \"instagram_handle\" : \"\",
           \"user\" : \"061a0de7-f269-4d4a-a31b-5aca9b694168\",
           \"photo\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/hosts/derived/6696ae98-9721-452f-bed4-77cbe28bf266.jpg\",
           \"opted_into_marketing\" : false
         },
         \"location\" : {
           \"address_city\" : \"Ilford\",
           \"address_street\" : \"Loxford School of Science Oxford\",
           \"address_building\" : \"\",
           \"company\" : {
             \"name\" : \"Workfindertesting12\",
             \"logo\" : null,
             \"uuid\" : \"49c323da-2433-496c-bf3e-b04e617babb0\"
           },
           \"uuid\" : \"32adf339-221d-4712-bd2f-cd0189998377\",
           \"address_unit\" : \"\",
           \"address_region\" : \"Essex\",
           \"address_country\" : \"GB\",
           \"address_postcode\" : \"IG12UT\"
         }
       },
       \"recommender\" : {
         \"scorers\" : [
           {
             \"class\" : \"DistanceScorer\",
             \"weight\" : 0.10000000000000001
           },
           {
             \"host_period\" : 90,
             \"placement_period\" : 30,
             \"weight\" : 0.20000000000000001,
             \"class\" : \"ActivityScorer\",
             \"weights\" : {
               \"accepted\" : 0.20000000000000001,
               \"viewed\" : 0.20000000000000001,
               \"created_recently\" : 0.5,
               \"time_since_last_log_in\" : 0.10000000000000001
             }
           },
           {
             \"class\" : \"HostProjectUCASScorer\",
             \"weight\" : 0
           },
           {
             \"class\" : \"ProjectBoosterScorer\",
             \"weight\" : 0.25
           },
           {
             \"class\" : \"SubjectTagScorer\",
             \"weight\" : 0
           },
           {
             \"class\" : \"ProjectUCASScorer\",
             \"weight\" : 0.45000000000000001
           }
         ],
         \"relevancy\" : 5,
         \"builders\" : [
           {
             \"class\" : \"ProjectsOnlyBuilder\",
             \"description\" : \"Only associations with an open project\"
           },
           {
             \"max_radius\" : 10,
             \"max_companies\" : 300,
             \"class\" : \"GeographicBuilder\",
             \"description\" : \"Nearest 300 companies within 10 km radius\"
           }
         ]
       },
       \"sent_at\" : \"2020-10-16T06:06:09.617459Z\",
       \"confidence\" : 0.73533793718503504,
       \"created_at\" : \"2020-10-16T06:06:09.161746Z\",
       \"uuid\" : \"23359ac0-4a3f-42a6-a8e7-832fd6e974fd\",
       \"project\" : {
         \"is_remote\" : true,
         \"host_activities\" : [
           \"Comprehensive analysis and report\",
           \"Create sales battlecards\",
           \"Competitive benchmarking process\",
           \"Identify primary, secondary and tertiary competitors\"
         ],
         \"start_date\" : null,
         \"is_paid\" : true,
         \"uuid\" : \"16b2becb-b79c-4446-9516-a56ae7744fcc\",
         \"duration\" : \"\",
         \"description\" : \"We’re looking for students to complete a short work placement focused on generating creative digital marketing content. You’ll be responsible for analysing the performance of previous content, understanding the target market’s motivations, and creating a new content and delivery calendar to meet our needs. Working alongside the marketing function of the business you’ll have the chance to hone your skills and learn more about working in digital marketing whilst adding real value to the business.\",
         \"type\" : \"Creative Digital Marketing\",
         \"name\" : \"Creative Digital Marketing\",
         \"association\" : {
           \"title\" : \"Application Testing Intern at Workfinder\",
           \"host\" : {
             \"uuid\" : \"6696ae98-9721-452f-bed4-77cbe28bf266\",
             \"full_name\" : \"Shiven Senthilkumar\",
             \"description\" : \"\",
             \"phone\" : \"07953396514\",
             \"associations\" : [
               \"a6057bf5-379d-43f3-8616-c5704570fab9\"
             ],
             \"photo_thumbnails\" : {
               \"m\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/6696ae98-9721-452f-bed4-77cbe28bf266.jpg.512x512_q85.jpg\",
               \"s-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/6696ae98-9721-452f-bed4-77cbe28bf266.jpg.256x256_q85_crop.jpg\",
               \"s\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/6696ae98-9721-452f-bed4-77cbe28bf266.jpg.256x256_q85.jpg\",
               \"l-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/6696ae98-9721-452f-bed4-77cbe28bf266.jpg.1024x1024_q85_crop.jpg\",
               \"l\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/6696ae98-9721-452f-bed4-77cbe28bf266.jpg.1024x1024_q85.jpg\",
               \"m-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/6696ae98-9721-452f-bed4-77cbe28bf266.jpg.512x512_q85_crop.jpg\"
             },
             \"names\" : [
               \"Shiven Senthilkumar\"
             ],
             \"twitter_handle\" : \"\",
             \"linkedin_url\" : \"https://linkedin.com/in/shiven-s\",
             \"friendly_name\" : \"\",
             \"emails\" : [
               \"shiven.senthilkumar+testinghost@workfinder.com\",
               \"shivens@live.co.uk\"
             ],
             \"instagram_handle\" : \"\",
             \"user\" : \"061a0de7-f269-4d4a-a31b-5aca9b694168\",
             \"photo\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/hosts/derived/6696ae98-9721-452f-bed4-77cbe28bf266.jpg\",
             \"opted_into_marketing\" : false
           },
           \"location\" : {
             \"address_city\" : \"Ilford\",
             \"address_street\" : \"Loxford School of Science Oxford\",
             \"address_building\" : \"\",
             \"company\" : {
               \"name\" : \"Workfindertesting12\",
               \"logo\" : null,
               \"uuid\" : \"49c323da-2433-496c-bf3e-b04e617babb0\"
             },
             \"uuid\" : \"32adf339-221d-4712-bd2f-cd0189998377\",
             \"address_unit\" : \"\",
             \"address_region\" : \"Essex\",
             \"address_country\" : \"GB\",
             \"address_postcode\" : \"IG12UT\"
           }
         }
       },
       \"user\" : \"249a185a-a62b-4c93-b4b3-7169bd01f131\"
     },
     {
       \"association\" : {
         \"title\" : \"Delivery Manager at Workfinder\",
         \"host\" : {
           \"uuid\" : \"69504065-0b44-49d5-84f2-1177d96df74c\",
           \"full_name\" : \"Abbie Burnett\",
           \"description\" : \"\",
           \"phone\" : \"07507123456\",
           \"associations\" : [
             \"040fc958-f434-4ea6-86c9-45bad17d9d92\",
             \"e8f851d5-873c-4e92-b36e-ef969ae40377\",
             \"4a27f9f4-9786-4568-ac3e-3113d4ebbf44\",
             \"986f582d-91a0-4d96-8be5-c7266a6782af\",
             \"86b343c9-ccf2-41f5-9b7c-569a5828dd53\",
             \"b2a49cc6-16dc-4342-9b2b-759dbedec0b4\",
             \"a4ede3e7-6946-4ed8-b7cb-2f695bf267e2\",
             \"199093f5-0ba9-4a7f-a02c-6f4551942d0b\",
             \"95445dff-d7d0-4d41-bf2e-dc4a36268471\",
             \"cfae0f04-5df1-4768-b76e-62ccedf20157\",
             \"eae656c6-3ad6-4c87-abe9-fbf588add139\",
             \"b39df1c2-8425-4cba-ba46-aa4aa05febd8\",
             \"74e75086-ef1b-41c4-8a9b-595b934dcb3e\",
             \"2d072ea6-80cf-4f09-a301-addecd74a12e\",
             \"462c8f5f-6274-416e-9e07-7ee308547ae4\",
             \"28ca88a6-5fd6-443b-8fc0-d44b56193efe\",
             \"05943428-2a60-441f-a09f-becf1e5817c2\",
             \"5b2cde34-f015-4e12-b3d6-f5ed3e7db3e5\",
             \"110751bf-ab6d-4b82-b4c1-fbbc1820c127\",
             \"1a8208e0-f1d5-43f2-8588-067687b4a7ba\",
             \"8f83782f-3525-43fb-8b03-39e694fba070\",
             \"aa65108b-b4a4-4153-8964-301461622d15\"
           ],
           \"photo_thumbnails\" : {
             \"m\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/69504065-0b44-49d5-84f2-1177d96df74c.jpg.512x512_q85.jpg\",
             \"s-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/69504065-0b44-49d5-84f2-1177d96df74c.jpg.256x256_q85_crop.jpg\",
             \"s\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/69504065-0b44-49d5-84f2-1177d96df74c.jpg.256x256_q85.jpg\",
             \"l-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/69504065-0b44-49d5-84f2-1177d96df74c.jpg.1024x1024_q85_crop.jpg\",
             \"l\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/69504065-0b44-49d5-84f2-1177d96df74c.jpg.1024x1024_q85.jpg\",
             \"m-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/69504065-0b44-49d5-84f2-1177d96df74c.jpg.512x512_q85_crop.jpg\"
           },
           \"names\" : [
             \"Abbie Burnett\"
           ],
           \"twitter_handle\" : \"\",
           \"linkedin_url\" : \"https://linkedin.com/in/abbie-burnett-922251147\",
           \"friendly_name\" : \"\",
           \"emails\" : [
             \"abbie.burnett+tester@workfinder.com\",
             \"abbie.burnett@hotmail.co.uk\"
           ],
           \"instagram_handle\" : \"\",
           \"user\" : \"5d8d6da7-0047-4cca-8093-c66daf632697\",
           \"photo\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/hosts/derived/69504065-0b44-49d5-84f2-1177d96df74c.jpg\",
           \"opted_into_marketing\" : false
         },
         \"location\" : {
           \"address_city\" : \"London\",
           \"address_street\" : \"Tea building\",
           \"address_building\" : \"\",
           \"company\" : {
             \"name\" : \"Workfinder Testing\",
             \"logo\" : null,
             \"uuid\" : \"02c567b7-b37c-49af-bc56-36192d6bb793\"
           },
           \"uuid\" : \"737db20c-abbf-488c-a06f-1cec96164ed0\",
           \"address_unit\" : \"\",
           \"address_region\" : \"London\",
           \"address_country\" : \"GB\",
           \"address_postcode\" : \"WC1N 3AX\"
         }
       },
       \"recommender\" : {
         \"scorers\" : [
           {
             \"class\" : \"DistanceScorer\",
             \"weight\" : 0.10000000000000001
           },
           {
             \"host_period\" : 90,
             \"placement_period\" : 30,
             \"weight\" : 0.20000000000000001,
             \"class\" : \"ActivityScorer\",
             \"weights\" : {
               \"accepted\" : 0.20000000000000001,
               \"viewed\" : 0.20000000000000001,
               \"created_recently\" : 0.5,
               \"time_since_last_log_in\" : 0.10000000000000001
             }
           },
           {
             \"class\" : \"HostProjectUCASScorer\",
             \"weight\" : 0
           },
           {
             \"class\" : \"ProjectBoosterScorer\",
             \"weight\" : 0.25
           },
           {
             \"class\" : \"SubjectTagScorer\",
             \"weight\" : 0
           },
           {
             \"class\" : \"ProjectUCASScorer\",
             \"weight\" : 0.45000000000000001
           }
         ],
         \"relevancy\" : 5,
         \"builders\" : [
           {
             \"class\" : \"ProjectsOnlyBuilder\",
             \"description\" : \"Only associations with a project\"
           },
           {
             \"max_radius\" : 10,
             \"max_companies\" : 300,
             \"class\" : \"GeographicBuilder\",
             \"description\" : \"Nearest 300 companies within 10 km radius\"
           }
         ]
       },
       \"sent_at\" : \"2020-10-15T06:06:10.213691Z\",
       \"confidence\" : 0.76711741461720895,
       \"created_at\" : \"2020-10-12T13:19:40.256395Z\",
       \"uuid\" : \"81c6798d-84d9-495b-b459-6b29fd7d644f\",
       \"project\" : {
         \"is_remote\" : true,
         \"host_activities\" : [
           \"Comprehensive analysis and report\",
           \"Create sales battlecards\",
           \"Competitive benchmarking process\",
           \"Identify primary, secondary and tertiary competitors\"
         ],
         \"start_date\" : null,
         \"is_paid\" : true,
         \"uuid\" : \"94902750-5e24-4172-9f9d-64112a8704e6\",
         \"duration\" : \"\",
         \"description\" : \"We’re looking for students to complete a short work placement focused on generating creative digital marketing content. You’ll be responsible for analysing the performance of previous content, understanding the target market’s motivations, and creating a new content and delivery calendar to meet our needs. Working alongside the marketing function of the business you’ll have the chance to hone your skills and learn more about working in digital marketing whilst adding real value to the business.\",
         \"type\" : \"Creative Digital Marketing\",
         \"name\" : \"Creative Digital Marketing\",
         \"association\" : {
           \"title\" : \"Delivery Manager at Workfinder\",
           \"host\" : {
             \"uuid\" : \"69504065-0b44-49d5-84f2-1177d96df74c\",
             \"full_name\" : \"Abbie Burnett\",
             \"description\" : \"\",
             \"phone\" : \"07507123456\",
             \"associations\" : [
               \"040fc958-f434-4ea6-86c9-45bad17d9d92\",
               \"e8f851d5-873c-4e92-b36e-ef969ae40377\",
               \"4a27f9f4-9786-4568-ac3e-3113d4ebbf44\",
               \"986f582d-91a0-4d96-8be5-c7266a6782af\",
               \"86b343c9-ccf2-41f5-9b7c-569a5828dd53\",
               \"b2a49cc6-16dc-4342-9b2b-759dbedec0b4\",
               \"a4ede3e7-6946-4ed8-b7cb-2f695bf267e2\",
               \"199093f5-0ba9-4a7f-a02c-6f4551942d0b\",
               \"95445dff-d7d0-4d41-bf2e-dc4a36268471\",
               \"cfae0f04-5df1-4768-b76e-62ccedf20157\",
               \"eae656c6-3ad6-4c87-abe9-fbf588add139\",
               \"b39df1c2-8425-4cba-ba46-aa4aa05febd8\",
               \"74e75086-ef1b-41c4-8a9b-595b934dcb3e\",
               \"2d072ea6-80cf-4f09-a301-addecd74a12e\",
               \"462c8f5f-6274-416e-9e07-7ee308547ae4\",
               \"28ca88a6-5fd6-443b-8fc0-d44b56193efe\",
               \"05943428-2a60-441f-a09f-becf1e5817c2\",
               \"5b2cde34-f015-4e12-b3d6-f5ed3e7db3e5\",
               \"110751bf-ab6d-4b82-b4c1-fbbc1820c127\",
               \"1a8208e0-f1d5-43f2-8588-067687b4a7ba\",
               \"8f83782f-3525-43fb-8b03-39e694fba070\",
               \"aa65108b-b4a4-4153-8964-301461622d15\"
             ],
             \"photo_thumbnails\" : {
               \"m\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/69504065-0b44-49d5-84f2-1177d96df74c.jpg.512x512_q85.jpg\",
               \"s-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/69504065-0b44-49d5-84f2-1177d96df74c.jpg.256x256_q85_crop.jpg\",
               \"s\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/69504065-0b44-49d5-84f2-1177d96df74c.jpg.256x256_q85.jpg\",
               \"l-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/69504065-0b44-49d5-84f2-1177d96df74c.jpg.1024x1024_q85_crop.jpg\",
               \"l\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/69504065-0b44-49d5-84f2-1177d96df74c.jpg.1024x1024_q85.jpg\",
               \"m-sq\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/cache/thumbnails/hosts/derived/69504065-0b44-49d5-84f2-1177d96df74c.jpg.512x512_q85_crop.jpg\"
             },
             \"names\" : [
               \"Abbie Burnett\"
             ],
             \"twitter_handle\" : \"\",
             \"linkedin_url\" : \"https://linkedin.com/in/abbie-burnett-922251147\",
             \"friendly_name\" : \"\",
             \"emails\" : [
               \"abbie.burnett+tester@workfinder.com\",
               \"abbie.burnett@hotmail.co.uk\"
             ],
             \"instagram_handle\" : \"\",
             \"user\" : \"5d8d6da7-0047-4cca-8093-c66daf632697\",
             \"photo\" : \"https://api-workfinder-com-develop.s3.amazonaws.com/media/hosts/derived/69504065-0b44-49d5-84f2-1177d96df74c.jpg\",
             \"opted_into_marketing\" : false
           },
           \"location\" : {
             \"address_city\" : \"London\",
             \"address_street\" : \"Tea building\",
             \"address_building\" : \"\",
             \"company\" : {
               \"name\" : \"Workfinder Testing\",
               \"logo\" : null,
               \"uuid\" : \"02c567b7-b37c-49af-bc56-36192d6bb793\"
             },
             \"uuid\" : \"737db20c-abbf-488c-a06f-1cec96164ed0\",
             \"address_unit\" : \"\",
             \"address_region\" : \"London\",
             \"address_country\" : \"GB\",
             \"address_postcode\" : \"WC1N 3AX\"
           }
         }
       },
       \"user\" : \"249a185a-a62b-4c93-b4b3-7169bd01f131\"
     }
   ],
   \"count\" : 9,
   \"next\" : null
 
 */
