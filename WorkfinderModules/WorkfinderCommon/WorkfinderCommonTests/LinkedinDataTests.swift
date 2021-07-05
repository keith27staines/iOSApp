//
//  LinkedinDataTests.swift
//  WorkfinderCommonTests
//
//  Created by Keith on 01/07/2021.
//  Copyright © 2021 Workfinder. All rights reserved.
//

import Foundation

import XCTest
import WorkfinderCommon

class LinkedinDataTests: XCTestCase {
    
    func test_string() throws {
        let json = _linkedinConnectionJsonString
        let data = json.data(using: .utf8)!
        let connection = try JSONDecoder().decode(LinkedinConnectionData.self, from: data)
        let extraData = connection.extra_data
        XCTAssertNotNil(extraData)
        XCTAssertEqual(extraData?.id, "SpkQIcdaqU")
        XCTAssertEqual(extraData?.educations?.count, 1)
        let skills = extraData?.skills
        //XCTAssertNotNil(extraData.skills["1"])
        //XCTAssertTrue(extraData.positions?.count > 0)
    }
}

fileprivate let _linkedinConnectionJsonString: String = """

  {
    \"id\" : 78,
    \"extra_data\" : {
      \"id\" : \"SpkQIcdaqU\",
      \"positions\" : {
        \"1045396350\" : {
          \"id\" : 1045396350,
          \"locationName\" : {
            \"localized\" : {
              \"en_US\" : \"Yeovil\"
            },
            \"preferredLocale\" : {
              \"country\" : \"US\",
              \"language\" : \"en\"
            }
          },
          \"title\" : {
            \"localized\" : {
              \"en_US\" : \"iOS Developer and software architect\"
            },
            \"preferredLocale\" : {
              \"country\" : \"US\",
              \"language\" : \"en\"
            }
          },
          \"geoPositionLocation\" : {
            \"displayLocationName\" : {
              \"localized\" : {
                \"en_US\" : \"Yeovil\"
              },
              \"preferredLocale\" : {
                \"country\" : \"US\",
                \"language\" : \"en\"
              }
            },
            \"localizedDisplayLocationName\" : \"Yeovil\"
          },
          \"startMonthYear\" : {
            \"month\" : 8,
            \"year\" : 2016
          },
          \"endMonthYear\" : {
            \"month\" : 7,
            \"year\" : 2017
          },
          \"companyName\" : {
            \"localized\" : {
              \"en_US\" : \"Leonardo Helicopters\"
            },
            \"preferredLocale\" : {
              \"country\" : \"US\",
              \"language\" : \"en\"
            }
          },
          \"description\" : {
            \"localized\" : {
              \"en_US\" : {
                \"rawText\" : \"iOS developer and software architect working on the Helipad project, developing electronic flight bag software for aircrew flying search and rescue missions\"
              }
            },
            \"preferredLocale\" : {
              \"country\" : \"US\",
              \"language\" : \"en\"
            }
          }
        },
        \"1587694350\" : {
          \"id\" : 1587694350,
          \"title\" : {
            \"$anti_abuse_annotations\" : [
              {
                \"entityId\" : 2,
                \"attributeId\" : 36
              }
            ],
            \"localized\" : {
              \"en_US\" : \"iOS Developer\"
            },
            \"preferredLocale\" : {
              \"country\" : \"US\",
              \"language\" : \"en\"
            }
          },
          \"description\" : {
            \"localized\" : {
              \"en_US\" : {
                \"rawText\" : \"This is some test text\"
              }
            },
            \"preferredLocale\" : {
              \"country\" : \"US\",
              \"language\" : \"en\"
            }
          },
          \"companyName\" : {
            \"localized\" : {
              \"en_US\" : \"Workfinder LTD\"
            },
            \"preferredLocale\" : {
              \"country\" : \"US\",
              \"language\" : \"en\"
            }
          },
          \"startMonthYear\" : {
            \"month\" : 8,
            \"year\" : 2019
          }
        },
        \"1283240383\" : {
          \"id\" : 1283240383,
          \"title\" : {
            \"localized\" : {
              \"en_US\" : \"iOS Developer\"
            },
            \"preferredLocale\" : {
              \"country\" : \"US\",
              \"language\" : \"en\"
            }
          },
          \"company\" : \"urn:li:organization:2967659\",
          \"endMonthYear\" : {
            \"month\" : 8,
            \"year\" : 2019
          },
          \"companyName\" : {
            \"localized\" : {
              \"en_US\" : \"Founders4Schools\"
            },
            \"preferredLocale\" : {
              \"country\" : \"US\",
              \"language\" : \"en\"
            }
          },
          \"startMonthYear\" : {
            \"year\" : 2017
          }
        }
      },
      \"lastName\" : {
        \"localized\" : {
          \"en_US\" : \"Staines\"
        },
        \"preferredLocale\" : {
          \"country\" : \"US\",
          \"language\" : \"en\"
        }
      },
      \"skills\" : {
        \"1\" : {
          \"name\" : {
            \"localized\" : {
              \"en_US\" : \"Programming\"
            },
            \"preferredLocale\" : {
              \"country\" : \"US\",
              \"language\" : \"en\"
            }
          },
          \"id\" : 1
        },
        \"2\" : {
          \"name\" : {
            \"localized\" : {
              \"en_US\" : \"Software Design\"
            },
            \"preferredLocale\" : {
              \"country\" : \"US\",
              \"language\" : \"en\"
            }
          },
          \"id\" : 2
        },
        \"3\" : {
          \"name\" : {
            \"localized\" : {
              \"en_US\" : \"Online Tutoring\"
            },
            \"preferredLocale\" : {
              \"country\" : \"US\",
              \"language\" : \"en\"
            }
          },
          \"id\" : 3
        }
      },
      \"localizedLastName\" : \"Staines\",
      \"headline\" : {
        \"localized\" : {
          \"en_US\" : \"iOS Developer at Workfinder LTD\"
        },
        \"preferredLocale\" : {
          \"country\" : \"US\",
          \"language\" : \"en\"
        }
      },
      \"educations\" : {
        \"440962795\" : {
          \"degreeName\" : {
            \"localized\" : {
              \"en_US\" : \"Doctor of Philosophy - PhD\"
            },
            \"preferredLocale\" : {
              \"country\" : \"US\",
              \"language\" : \"en\"
            }
          },
          \"id\" : 440962795,
          \"school\" : \"urn:li:organization:5106\",
          \"fieldsOfStudy\" : [
            {
              \"fieldOfStudyName\" : {
                \"localized\" : {
                  \"en_US\" : \"Physics\"
                },
                \"preferredLocale\" : {
                  \"country\" : \"US\",
                  \"language\" : \"en\"
                }
              }
            }
          ],
          \"schoolName\" : {
            \"localized\" : {
              \"en_US\" : \"Imperial College London\"
            },
            \"preferredLocale\" : {
              \"country\" : \"US\",
              \"language\" : \"en\"
            }
          }
        }
      },
      \"industryName\" : {
        \"localized\" : {
          \"en_US\" : \"Education Management\"
        },
        \"preferredLocale\" : {
          \"country\" : \"US\",
          \"language\" : \"en\"
        }
      },
      \"vanityName\" : \"keith-s-42b5a8148\",
      \"firstName\" : {
        \"localized\" : {
          \"en_US\" : \"Keith\"
        },
        \"preferredLocale\" : {
          \"country\" : \"US\",
          \"language\" : \"en\"
        }
      },
      \"supportedLocales\" : [
        {
          \"country\" : \"US\",
          \"language\" : \"en\"
        }
      ],
      \"profilePicture\" : {
        \"displayImage\" : \"urn:li:digitalmediaAsset:C5603AQHQ5fZCxyCnKA\",
        \"displayImage~\" : {
          \"elements\" : [
            {
              \"identifiers\" : [
                {
                  \"identifierType\" : \"EXTERNAL_URL\",
                  \"mediaType\" : \"image/jpeg\",
                  \"identifierExpiresInSeconds\" : 1630540800,
                  \"identifier\" : \"https://media-exp1.licdn.com/dms/image/C5603AQHQ5fZCxyCnKA/profile-displayphoto-shrink_100_100/0/1582717966586?e=1630540800&v=beta&t=9ccajpdVU5B6CoCWcd0nasYFaue4aWg-EXSADuzqf-I\",
                  \"file\" : \"urn:li:digitalmediaFile:(urn:li:digitalmediaAsset:C5603AQHQ5fZCxyCnKA,urn:li:digitalmediaMediaArtifactClass:profile-displayphoto-shrink_100_100,0)\",
                  \"index\" : 0
                }
              ],
              \"data\" : {
                \"com.linkedin.digitalmedia.mediaartifact.StillImage\" : {
                  \"storageAspectRatio\" : {
                    \"widthAspect\" : 1,
                    \"heightAspect\" : 1,
                    \"formatted\" : \"1.00:1.00\"
                  },
                  \"mediaType\" : \"image/jpeg\",
                  \"rawCodecSpec\" : {
                    \"name\" : \"jpeg\",
                    \"type\" : \"image\"
                  },
                  \"displaySize\" : {
                    \"width\" : 100,
                    \"uom\" : \"PX\",
                    \"height\" : 100
                  },
                  \"storageSize\" : {
                    \"width\" : 100,
                    \"height\" : 100
                  },
                  \"displayAspectRatio\" : {
                    \"widthAspect\" : 1,
                    \"heightAspect\" : 1,
                    \"formatted\" : \"1.00:1.00\"
                  }
                }
              },
              \"authorizationMethod\" : \"PUBLIC\",
              \"artifact\" : \"urn:li:digitalmediaMediaArtifact:(urn:li:digitalmediaAsset:C5603AQHQ5fZCxyCnKA,urn:li:digitalmediaMediaArtifactClass:profile-displayphoto-shrink_100_100)\"
            },
            {
              \"identifiers\" : [
                {
                  \"identifierType\" : \"EXTERNAL_URL\",
                  \"mediaType\" : \"image/jpeg\",
                  \"identifierExpiresInSeconds\" : 1630540800,
                  \"identifier\" : \"https://media-exp1.licdn.com/dms/image/C5603AQHQ5fZCxyCnKA/profile-displayphoto-shrink_200_200/0/1582717966586?e=1630540800&v=beta&t=PC_wneELpMNg9nkF-Pw9dLCgJZn3ImOe8dIb-asqtt0\",
                  \"file\" : \"urn:li:digitalmediaFile:(urn:li:digitalmediaAsset:C5603AQHQ5fZCxyCnKA,urn:li:digitalmediaMediaArtifactClass:profile-displayphoto-shrink_200_200,0)\",
                  \"index\" : 0
                }
              ],
              \"data\" : {
                \"com.linkedin.digitalmedia.mediaartifact.StillImage\" : {
                  \"storageAspectRatio\" : {
                    \"widthAspect\" : 1,
                    \"heightAspect\" : 1,
                    \"formatted\" : \"1.00:1.00\"
                  },

                  \"mediaType\" : \"image/jpeg\",
                  \"rawCodecSpec\" : {
                    \"name\" : \"jpeg\",
                    \"type\" : \"image\"
                  },
                  \"displaySize\" : {
                    \"width\" : 200,
                    \"uom\" : \"PX\",
                    \"height\" : 200
                  },
                  \"storageSize\" : {
                    \"width\" : 200,
                    \"height\" : 200
                  },
                  \"displayAspectRatio\" : {
                    \"widthAspect\" : 1,
                    \"heightAspect\" : 1,
                    \"formatted\" : \"1.00:1.00\"
                  }
                }
              },
              \"authorizationMethod\" : \"PUBLIC\",
              \"artifact\" : \"urn:li:digitalmediaMediaArtifact:(urn:li:digitalmediaAsset:C5603AQHQ5fZCxyCnKA,urn:li:digitalmediaMediaArtifactClass:profile-displayphoto-shrink_200_200)\"
            },
            {

              \"identifiers\" : [
                {
                  \"identifierType\" : \"EXTERNAL_URL\",
                  \"mediaType\" : \"image/jpeg\",
                  \"identifierExpiresInSeconds\" : 1630540800,
                  \"identifier\" : \"https://media-exp1.licdn.com/dms/image/C5603AQHQ5fZCxyCnKA/profile-displayphoto-shrink_400_400/0/1582717966586?e=1630540800&v=beta&t=IRYfaQxp7EStxU8uRrX2awvtgS1zHFCA4IqcMsRr15c\",
                  \"file\" : \"urn:li:digitalmediaFile:(urn:li:digitalmediaAsset:C5603AQHQ5fZCxyCnKA,urn:li:digitalmediaMediaArtifactClass:profile-displayphoto-shrink_400_400,0)\",
                  \"index\" : 0
                }
              ],
              \"data\" : {
                \"com.linkedin.digitalmedia.mediaartifact.StillImage\" : {
                  \"storageAspectRatio\" : {
                    \"widthAspect\" : 1,
                    \"heightAspect\" : 1,
                    \"formatted\" : \"1.00:1.00\"
                  },
                  \"mediaType\" : \"image/jpeg\",
                  \"rawCodecSpec\" : {
                    \"name\" : \"jpeg\",
                    \"type\" : \"image\"
                  },
                  \"displaySize\" : {
                    \"width\" : 400,
                    \"uom\" : \"PX\",
                    \"height\" : 400
                  },
                  \"storageSize\" : {
                    \"width\" : 400,
                    \"height\" : 400
                  },
                  \"displayAspectRatio\" : {
                    \"widthAspect\" : 1,
                    \"heightAspect\" : 1,
                    \"formatted\" : \"1.00:1.00\"
                  }
                }
              },
              \"authorizationMethod\" : \"PUBLIC\",
              \"artifact\" : \"urn:li:digitalmediaMediaArtifact:(urn:li:digitalmediaAsset:C5603AQHQ5fZCxyCnKA,urn:li:digitalmediaMediaArtifactClass:profile-displayphoto-shrink_400_400)\"
            },
            {
              \"identifiers\" : [
                {
                  \"identifierType\" : \"EXTERNAL_URL\",
                  \"mediaType\" : \"image/jpeg\",
                  \"identifierExpiresInSeconds\" : 1630540800,
                  \"identifier\" : \"https://media-exp1.licdn.com/dms/image/C5603AQHQ5fZCxyCnKA/profile-displayphoto-shrink_800_800/0/1582717966586?e=1630540800&v=beta&t=NHJyf6hz6CDA0oU4hdBVQ1czFC0NRwD1hn6r1M4_mmo\",
                  \"file\" : \"urn:li:digitalmediaFile:(urn:li:digitalmediaAsset:C5603AQHQ5fZCxyCnKA,urn:li:digitalmediaMediaArtifactClass:profile-displayphoto-shrink_800_800,0)\",
                  \"index\" : 0
                }
              ],
              \"data\" : {
                \"com.linkedin.digitalmedia.mediaartifact.StillImage\" : {
                  \"storageAspectRatio\" : {
                    \"widthAspect\" : 1,
                    \"heightAspect\" : 1,
                    \"formatted\" : \"1.00:1.00\"
                  },
                  \"mediaType\" : \"image/jpeg\",
                  \"rawCodecSpec\" : {
                    \"name\" : \"jpeg\",
                    \"type\" : \"image\"
                  },
                  \"displaySize\" : {
                    \"width\" : 800,
                    \"uom\" : \"PX\",
                    \"height\" : 800
                  },
                  \"storageSize\" : {
                    \"width\" : 800,
                    \"height\" : 800
                  },
                  \"displayAspectRatio\" : {
                    \"widthAspect\" : 1,
                    \"heightAspect\" : 1,
                    \"formatted\" : \"1.00:1.00\"
                  }
                }
              },
              \"authorizationMethod\" : \"PUBLIC\",
              \"artifact\" : \"urn:li:digitalmediaMediaArtifact:(urn:li:digitalmediaAsset:C5603AQHQ5fZCxyCnKA,urn:li:digitalmediaMediaArtifactClass:profile-displayphoto-shrink_800_800)\"
            }
          ],
          \"paging\" : {
            \"count\" : 10,
            \"start\" : 0,
            \"links\" : [

            ]
          }
        }
      },
      \"geoLocation\" : {
        \"geo\" : \"urn:li:geo:103910516\",
        \"autoGenerated\" : true
      },
      \"summary\" : {
        \"localized\" : {
          \"en_US\" : {
            \"rawText\" : \"Originally I trained as a physicist and then worked in nuclear power stations and on space programmes for ESA and NASA. I moved into software development  in 1996. My ideal job would combine physics, mathematics and coding, and that's pretty much what I have been doing for the last few years.\"
          }
        },
        \"preferredLocale\" : {
          \"country\" : \"US\",
          \"language\" : \"en\"
        }
      },
      \"location\" : {
        \"countryCode\" : \"gb\",
        \"userSelectedGeoPlaceCode\" : \"1-0-59-126\",
        \"standardizedLocationUrn\" : \"urn:li:standardizedLocationKey:(gb,TA18 7HY)\",
        \"postalCode\" : \"TA18 7HY\"
      },
      \"industryId\" : \"urn:li:industry:69\",
      \"localizedFirstName\" : \"Keith\",
      \"lastModified\" : 1582717968604,
      \"elements\" : [
        {
          \"handle~\" : {
            \"emailAddress\" : \"keith27staines@icloud.com\"
          },
          \"handle\" : \"urn:li:emailAddress:6130416671\"
        }
      ]
    },
    \"provider\" : \"linkedin_oauth2\"
  }

"""
