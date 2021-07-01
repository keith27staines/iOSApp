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
    
    func test_string() {
        let s = _linkedinJsonString
        
    }
}


fileprivate let _linkedinJsonString = '''
{
  "elements": [
    {
      "handle~": {
        "emailAddress": "kristo773@hotmail.com"
      },
      "handle": "urn:li:emailAddress:545841023"
    }
  ],
  "lastName": {
    "localized": {
      "en_US": "Mikkonen"
    },
    "preferredLocale": {
      "country": "US",
      "language": "en"
    }
  },
  "educations": {
    "83032218": {
      "startMonthYear": {
        "year": 2009
      },
      "notes": {
        "localized": {
          "en_US": {
            "rawText": "This joint degree aims to provide its graduates with the knowledge and skills necessary to work in the technical field of computer science and information systems design and at the same time to understand the fundamentals of markets, organizations and business management."
          }
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "endMonthYear": {
        "year": 2013
      },
      "school": "urn:li:organization:6679",
      "fieldsOfStudy": [
        {
          "fieldOfStudyName": {
            "localized": {
              "en_US": "Computer Science & Business"
            },
            "preferredLocale": {
              "country": "US",
              "language": "en"
            }
          }
        }
      ],
      "degreeName": {
        "localized": {
          "en_US": "Bachelor of Arts (B.A.)"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 83032218,
      "schoolName": {
        "localized": {
          "en_US": "Trinity College, Dublin"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      }
    },
    "187396444": {
      "startMonthYear": {
        "year": 2013
      },
      "notes": {
        "localized": {
          "en_US": {
            "rawText": "The programme offers discipline-based training combined with empirical application, drawing on the experience of the 28 nations that have emerged from the former Soviet block in Europe and Asia. Students are equipped with strong foundations in both international business and economics as well as in finance and corporate governance."
          }
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "endMonthYear": {
        "year": 2014
      },
      "school": "urn:li:organization:4171",
      "fieldsOfStudy": [
        {
          "fieldOfStudyName": {
            "localized": {
              "en_US": "Comparative Business Economics"
            },
            "preferredLocale": {
              "country": "US",
              "language": "en"
            }
          }
        }
      ],
      "degreeName": {
        "localized": {
          "en_US": "Master of Arts (MA)"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 187396444,
      "schoolName": {
        "localized": {
          "en_US": "University College London, U. of London"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      }
    }
  },
  "skills": {
    "1": {
      "name": {
        "localized": {
          "en_US": "Node.js"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 1
    },
    "2": {
      "name": {
        "localized": {
          "en_US": "Realtime Programming"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 2
    },
    "3": {
      "name": {
        "localized": {
          "en_US": "Finnish Language"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 3
    },
    "4": {
      "name": {
        "localized": {
          "en_US": "Programming"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 4
    },
    "5": {
      "name": {
        "localized": {
          "en_US": "APIs"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 5
    },
    "6": {
      "name": {
        "localized": {
          "en_US": "Finnish"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 6
    },
    "7": {
      "name": {
        "localized": {
          "en_US": "C++"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 7
    },
    "8": {
      "name": {
        "localized": {
          "en_US": "Java"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 8
    },
    "9": {
      "name": {
        "localized": {
          "en_US": "JavaScript"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 9
    },
    "10": {
      "name": {
        "localized": {
          "en_US": "Python"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 10
    },
    "11": {
      "name": {
        "localized": {
          "en_US": "Flight Simulation"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 11
    },
    "22": {
      "name": {
        "localized": {
          "en_US": "International Business"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 22
    },
    "23": {
      "name": {
        "localized": {
          "en_US": "CAPM"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 23
    },
    "24": {
      "name": {
        "localized": {
          "en_US": "Agile Methodologies"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 24
    },
    "25": {
      "name": {
        "localized": {
          "en_US": "MySQL"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 25
    },
    "26": {
      "name": {
        "localized": {
          "en_US": "HTML"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 26
    },
    "27": {
      "name": {
        "localized": {
          "en_US": "Android Development"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 27
    },
    "28": {
      "name": {
        "localized": {
          "en_US": "CSS"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 28
    },
    "29": {
      "name": {
        "localized": {
          "en_US": "Waterfall"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 29
    },
    "30": {
      "name": {
        "localized": {
          "en_US": "Lounge"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 30
    },
    "31": {
      "name": {
        "localized": {
          "en_US": "Straight Talking"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 31
    },
    "32": {
      "name": {
        "localized": {
          "en_US": "Analysts"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 32
    },
    "33": {
      "name": {
        "localized": {
          "en_US": "Distributed Systems"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 33
    },
    "35": {
      "name": {
        "localized": {
          "en_US": "AJAX"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 35
    },
    "37": {
      "name": {
        "localized": {
          "en_US": "Scrum"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 37
    },
    "38": {
      "name": {
        "localized": {
          "en_US": "HTML5"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 38
    },
    "39": {
      "name": {
        "localized": {
          "en_US": "PHP"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 39
    },
    "40": {
      "name": {
        "localized": {
          "en_US": "Software Engineering"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 40
    },
    "208960316": {
      "name": {
        "localized": {
          "en_US": "Sauna"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 208960316
    },
    "574218666": {
      "name": {
        "localized": {
          "en_US": "RESTful WebServices"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 574218666
    },
    "574218667": {
      "name": {
        "localized": {
          "en_US": "SQL"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 574218667
    },
    "574218668": {
      "name": {
        "localized": {
          "en_US": "Influencer Marketing"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 574218668
    },
    "1956760490": {
      "name": {
        "localized": {
          "en_US": "Cascading Style Sheets (CSS)"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 1956760490
    },
    "1956761830": {
      "name": {
        "localized": {
          "en_US": "Microsoft Office"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 1956761830
    }
  },
  "industryId": "urn:li:industry:96",
  "id": "wkjRLSuhdy",
  "headline": {
    "localized": {
      "en_US": "Senior Software Engineer at Digital Boost"
    },
    "preferredLocale": {
      "country": "US",
      "language": "en"
    }
  },
  "localizedFirstName": "Kristo",
  "industryName": {
    "localized": {
      "en_US": "Information Technology & Services"
    },
    "preferredLocale": {
      "country": "US",
      "language": "en"
    }
  },
  "localizedLastName": "Mikkonen",
  "vanityName": "thekristomikkonen",
  "supportedLocales": [
    {
      "country": "US",
      "language": "en"
    }
  ],
  "languages": {
    "14": {
      "name": {
        "localized": {
          "en_US": "English"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "proficiency": "NATIVE_OR_BILINGUAL",
      "id": 14
    },
    "15": {
      "name": {
        "localized": {
          "en_US": "Finnish"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "proficiency": "NATIVE_OR_BILINGUAL",
      "id": 15
    }
  },
  "positions": {
    "218659250": {
      "startMonthYear": {
        "month": 5,
        "year": 2011,
        "$anti_abuse_annotations": [
          {
            "attributeId": 34,
            "entityId": 2
          },
          {
            "attributeId": 35,
            "entityId": 2
          }
        ]
      },
      "locationName": {
        "localized": {
          "en_US": "Dublin, Ireland."
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "endMonthYear": {
        "month": 10,
        "year": 2011
      },
      "companyName": {
        "localized": {
          "en_US": "Activision"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "description": {
        "localized": {
          "en_US": {
            "rawText": "Activision is a leading video game publisher. The role included translating and localizing titles such as Call of Duty and Spyro: Skylanders’ Adventure. I was responsible for ensuring the Finnish versions of many titles were technically, linguistically and culturally sound."
          }
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "company": "urn:li:organization:4048",
      "id": 218659250,
      "title": {
        "localized": {
          "en_US": "Quality Assurance Localisation Tester (Finnish)"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "geoPositionLocation": {
        "displayLocationName": {
          "localized": {
            "en_US": "Dublin, Ireland."
          },
          "preferredLocale": {
            "country": "US",
            "language": "en"
          }
        },
        "localizedDisplayLocationName": "Dublin, Ireland."
      }
    },
    "276094334": {
      "startMonthYear": {
        "month": 5,
        "year": 2011
      },
      "locationName": {
        "localized": {
          "en_US": "Dublin, Ireland"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "endMonthYear": {
        "month": 5,
        "year": 2012
      },
      "companyName": {
        "localized": {
          "en_US": "Analyst Lounge"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "company": "urn:li:organization:3239292",
      "id": 276094334,
      "title": {
        "localized": {
          "en_US": "Developer and Founder"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "geoPositionLocation": {
        "displayLocationName": {
          "localized": {
            "en_US": "Dublin, Ireland"
          },
          "preferredLocale": {
            "country": "US",
            "language": "en"
          }
        },
        "localizedDisplayLocationName": "Dublin, Ireland"
      }
    },
    "301689303": {
      "startMonthYear": {
        "month": 6,
        "year": 2012
      },
      "company": "urn:li:organization:166818",
      "id": 301689303,
      "title": {
        "localized": {
          "en_US": "Programmer Intern"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "endMonthYear": {
        "month": 8,
        "year": 2012
      },
      "companyName": {
        "localized": {
          "en_US": "VistaTEC"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      }
    },
    "325863587": {
      "startMonthYear": {
        "month": 5,
        "year": 2012
      },
      "locationName": {
        "localized": {
          "en_US": "Trinity College Dublin, Ireland"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "endMonthYear": {
        "month": 7,
        "year": 2012
      },
      "companyName": {
        "localized": {
          "en_US": "Centre for Next Generation Localisation (CNGL)"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "description": {
        "localized": {
          "en_US": {
            "rawText": "Completed an internship with the Centre for Next Generation Localisation (CNGL), a university research group with many industry partners. My role was to implement and configure analytical tools, that were spin-offs of the CNGL’s research for an industry partner.\n\nWorked mainly with Tomcat, Java, RDF, SPARQL and XSLT."
          }
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "id": 325863587,
      "title": {
        "localized": {
          "en_US": "Research Programmer Intern"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "geoPositionLocation": {
        "displayLocationName": {
          "localized": {
            "en_US": "Trinity College Dublin, Ireland"
          },
          "preferredLocale": {
            "country": "US",
            "language": "en"
          }
        },
        "localizedDisplayLocationName": "Trinity College Dublin, Ireland"
      }
    },
    "422861792": {
      "startMonthYear": {
        "month": 6,
        "year": 2013
      },
      "locationName": {
        "localized": {
          "en_US": "Dublin, Ireland"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "endMonthYear": {
        "month": 9,
        "year": 2013
      },
      "companyName": {
        "localized": {
          "en_US": "Google"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "description": {
        "localized": {
          "en_US": {
            "rawText": "During my internship I developed and maintained a web application for the Business Intelligence team within Google Enterprise. Projects I worked on also included implementing feature requests and migrating data across different Google products. \n\nWorked mainly with Google App Engine, Python, HTML, CSS and JavaScript."
          }
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "company": "urn:li:organization:1441",
      "id": 422861792,
      "title": {
        "localized": {
          "en_US": "Developer Intern"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "geoPositionLocation": {
        "displayLocationName": {
          "localized": {
            "en_US": "Dublin, Ireland"
          },
          "preferredLocale": {
            "country": "US",
            "language": "en"
          }
        },
        "localizedDisplayLocationName": "Dublin, Ireland"
      }
    },
    "574218665": {
      "startMonthYear": {
        "month": 5,
        "year": 2014
      },
      "locationName": {
        "localized": {
          "en_US": "London, United Kingdom"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "endMonthYear": {
        "month": 11,
        "year": 2015
      },
      "companyName": {
        "localized": {
          "en_US": "Tailify"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "description": {
        "localized": {
          "en_US": {
            "rawText": "Through our platform, we are an intermediate between brands and social media influencers. We enable brands and social media influencers to work together to create beautiful, high-impact advertising campaigns primarily on Instagram. \n\nWe operate in the fastest growing advertising segment, and we thrive through our influencer algorithm and proprietary technology. Our clients are top tier media agencies and global brands such as Coca Cola, Disney and Marc Jacobs. \n\nSince September 2014 we are venture-backed with funding from Seed Capital.\n\nMy role:\n\nLeading a team of developers.\nDesign and implementation of Tailify's web infrastructure.\nDeveloping data capture and analysis tools for social media data. \nWorking mainly with Amazon Web Services, Python, SQL and PHP/ Laravel."
          }
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "company": "urn:li:organization:3502056",
      "location": {
        "countryCode": "gb",
        "regionCode": 4573
      },
      "id": 574218665,
      "title": {
        "localized": {
          "en_US": "CTO/Lead Developer"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "geoPositionLocation": {
        "displayLocationName": {
          "localized": {
            "en_US": "London, United Kingdom"
          },
          "preferredLocale": {
            "country": "US",
            "language": "en"
          }
        },
        "localizedDisplayLocationName": "London, United Kingdom"
      }
    },
    "742417174": {
      "startMonthYear": {
        "month": 9,
        "year": 2015
      },
      "locationName": {
        "localized": {
          "en_US": "London, United Kingdom"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "endMonthYear": {
        "month": 1,
        "year": 2016
      },
      "companyName": {
        "localized": {
          "en_US": "Gigwise"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "description": {
        "localized": {
          "en_US": {
            "rawText": "Gigwise Ltd is a leading independent online publishing company that owns and operates music website Gigwise.com. The company is looking to scale up its current business using investment and move its focus towards disrupting music journalism.\n\nWorking mainly with Amazon Web Services, Javascript, SQL and PHP/ Laravel."
          }
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "company": "urn:li:organization:10321738",
      "id": 742417174,
      "title": {
        "localized": {
          "en_US": "CTO/Lead Developer"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        },
        "$anti_abuse_annotations": [
          {
            "attributeId": 36,
            "entityId": 2
          }
        ]
      },
      "geoPositionLocation": {
        "displayLocationName": {
          "localized": {
            "en_US": "London, United Kingdom"
          },
          "preferredLocale": {
            "country": "US",
            "language": "en"
          }
        },
        "localizedDisplayLocationName": "London, United Kingdom"
      }
    },
    "828801867": {
      "startMonthYear": {
        "month": 2,
        "year": 2016
      },
      "locationName": {
        "localized": {
          "en_US": "London, United Kingdom"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "endMonthYear": {
        "month": 1,
        "year": 2017
      },
      "companyName": {
        "localized": {
          "en_US": "Fabacus"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "description": {
        "localized": {
          "en_US": {
            "rawText": "Fabacus is an established business, based out of Central London. Our Software Suite is trusted and used everyday by some of UK’s major retailers and manufacturers to help them increase productivity and get easy access to cutting edge business intelligence.  This allows businesses to realise their full potential by providing full data transparency and control over their business’ information.\n\nMy role includes:\n\nDeveloping integrations with between third party APIs such as Salesforce, Xero and Revel.\nCreating NPM packages for accessing third party eCommerce systems.\nDeveloping rapid prototypes.\nWorking with a great team of developers to release cutting edge technology products.\nTechnologies used: NodeJS, MongoDB, AWS, PHP/ Laravel, MySQL, AngularJS, React, Redux\n"
          }
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "company": "urn:li:organization:1831461",
      "location": {
        "countryCode": "gb",
        "regionCode": 4573
      },
      "id": 828801867,
      "title": {
        "localized": {
          "en_US": "Lead Developer"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "geoPositionLocation": {
        "displayLocationName": {
          "localized": {
            "en_US": "London, United Kingdom"
          },
          "preferredLocale": {
            "country": "US",
            "language": "en"
          }
        },
        "localizedDisplayLocationName": "London, United Kingdom"
      }
    },
    "923220057": {
      "startMonthYear": {
        "month": 2,
        "year": 2017
      },
      "locationName": {
        "localized": {
          "en_US": "London, United Kingdom"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "endMonthYear": {
        "month": 7,
        "year": 2018
      },
      "companyName": {
        "localized": {
          "en_US": "Somo Global"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "description": {
        "localized": {
          "en_US": {
            "rawText": "● Developed a tool for sorting and viewing financial information for a tier one investment bank.\n● Worked along side Java/AEM developers to develop features and tools for investment analysis.\n● Technologies used: React, NodeJS, Redux, Jest, SCSS, AEM, Java."
          }
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "company": "urn:li:organization:884658",
      "location": {
        "countryCode": "gb",
        "regionCode": 4573
      },
      "id": 923220057,
      "title": {
        "localized": {
          "en_US": "Senior Developer"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "geoPositionLocation": {
        "displayLocationName": {
          "localized": {
            "en_US": "London, United Kingdom"
          },
          "preferredLocale": {
            "country": "US",
            "language": "en"
          }
        },
        "localizedDisplayLocationName": "London, United Kingdom"
      }
    },
    "1343865058": {
      "startMonthYear": {
        "month": 7,
        "year": 2018
      },
      "locationName": {
        "localized": {
          "en_US": "London, United Kingdom"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "endMonthYear": {
        "month": 11,
        "year": 2019
      },
      "companyName": {
        "localized": {
          "en_US": "LVMH"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "description": {
        "localized": {
          "en_US": {
            "rawText": "Developing web apps for a variety of LVMH's brands.\n\nTechnologies used: JavaScript, Node, React, Redux, TypeScript."
          }
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "company": "urn:li:organization:164788",
      "location": {
        "countryCode": "gb",
        "regionCode": 4573
      },
      "id": 1343865058,
      "title": {
        "localized": {
          "en_US": "Senior Software Development Engineer"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "geoPositionLocation": {
        "displayLocationName": {
          "localized": {
            "en_US": "London, United Kingdom"
          },
          "preferredLocale": {
            "country": "US",
            "language": "en"
          }
        },
        "localizedDisplayLocationName": "London, United Kingdom"
      }
    },
    "1539730962": {
      "startMonthYear": {
        "month": 11,
        "year": 2019
      },
      "locationName": {
        "localized": {
          "en_US": "London, United Kingdom"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "endMonthYear": {
        "month": 4,
        "year": 2020
      },
      "companyName": {
        "localized": {
          "en_US": "Somo Global"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        },
        "$anti_abuse_annotations": [
          {
            "attributeId": 14,
            "entityId": 2
          }
        ]
      },
      "description": {
        "localized": {
          "en_US": {
            "rawText": "Developing features for audiusa.com \n\n● Technologies: React, NodeJS, Redux, Jest, SCSS, AEM, TypeScript"
          }
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "company": "urn:li:organization:884658",
      "location": {
        "countryCode": "gb",
        "regionCode": 4573
      },
      "id": 1539730962,
      "title": {
        "localized": {
          "en_US": "Senior Software Engineer"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        },
        "$anti_abuse_annotations": [
          {
            "attributeId": 36,
            "entityId": 2
          }
        ]
      },
      "geoPositionLocation": {
        "displayLocationName": {
          "localized": {
            "en_US": "London, United Kingdom"
          },
          "preferredLocale": {
            "country": "US",
            "language": "en"
          }
        },
        "localizedDisplayLocationName": "London, United Kingdom"
      }
    },
    "1649745773": {
      "startMonthYear": {
        "month": 4,
        "year": 2020
      },
      "locationName": {
        "localized": {
          "en_US": "London, England, United Kingdom"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "endMonthYear": {
        "month": 7,
        "year": 2020
      },
      "companyName": {
        "localized": {
          "en_US": "Den Creative"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "location": {
        "countryCode": "gb"
      },
      "company": "urn:li:organization:1394293",
      "id": 1649745773,
      "title": {
        "localized": {
          "en_US": "Senior Software Engineer"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "geoPositionLocation": {
        "displayLocationName": {
          "localized": {
            "en_US": "London, England, United Kingdom"
          },
          "preferredLocale": {
            "country": "US",
            "language": "en"
          }
        },
        "localizedDisplayLocationName": "London, England, United Kingdom"
      }
    },
    "1649748450": {
      "startMonthYear": {
        "month": 7,
        "year": 2020
      },
      "locationName": {
        "localized": {
          "en_US": "London, England, United Kingdom"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "companyName": {
        "localized": {
          "en_US": "Digital Boost"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "location": {
        "countryCode": "gb"
      },
      "company": "urn:li:organization:42782041",
      "id": 1649748450,
      "title": {
        "localized": {
          "en_US": "Senior Software Engineer"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        },
        "$anti_abuse_annotations": [
          {
            "attributeId": 36,
            "entityId": 2
          }
        ]
      },
      "geoPositionLocation": {
        "displayLocationName": {
          "localized": {
            "en_US": "London, England, United Kingdom"
          },
          "preferredLocale": {
            "country": "US",
            "language": "en"
          }
        },
        "localizedDisplayLocationName": "London, England, United Kingdom"
      }
    }
  },
  "firstName": {
    "localized": {
      "en_US": "Kristo"
    },
    "preferredLocale": {
      "country": "US",
      "language": "en"
    }
  },
  "profilePicture": {
    "displayImage": "urn:li:digitalmediaAsset:C5603AQEg4EFE_HXjmA",
    "displayImage~": {
      "paging": {
        "count": 10,
        "start": 0,
        "links": []
      },
      "elements": [
        {
          "artifact": "urn:li:digitalmediaMediaArtifact:(urn:li:digitalmediaAsset:C5603AQEg4EFE_HXjmA,urn:li:digitalmediaMediaArtifactClass:profile-displayphoto-shrink_100_100)",
          "authorizationMethod": "PUBLIC",
          "data": {
            "com.linkedin.digitalmedia.mediaartifact.StillImage": {
              "mediaType": "image/jpeg",
              "rawCodecSpec": {
                "name": "jpeg",
                "type": "image"
              },
              "displaySize": {
                "width": 100,
                "uom": "PX",
                "height": 100
              },
              "storageSize": {
                "width": 100,
                "height": 100
              },
              "storageAspectRatio": {
                "widthAspect": 1,
                "heightAspect": 1,
                "formatted": "1.00:1.00"
              },
              "displayAspectRatio": {
                "widthAspect": 1,
                "heightAspect": 1,
                "formatted": "1.00:1.00"
              }
            }
          },
          "identifiers": [
            {
              "identifier": "https://media-exp1.licdn.com/dms/image/C5603AQEg4EFE_HXjmA/profile-displayphoto-shrink_100_100/0/1516883336565?e=1628726400&v=beta&t=7t2H0D7SzGlBk4ILPcIrZd_FXpYBrFOZFLEjlpwLa44",
              "index": 0,
              "mediaType": "image/jpeg",
              "file": "urn:li:digitalmediaFile:(urn:li:digitalmediaAsset:C5603AQEg4EFE_HXjmA,urn:li:digitalmediaMediaArtifactClass:profile-displayphoto-shrink_100_100,0)",
              "identifierType": "EXTERNAL_URL",
              "identifierExpiresInSeconds": 1628726400
            }
          ]
        },
        {
          "artifact": "urn:li:digitalmediaMediaArtifact:(urn:li:digitalmediaAsset:C5603AQEg4EFE_HXjmA,urn:li:digitalmediaMediaArtifactClass:profile-displayphoto-shrink_200_200)",
          "authorizationMethod": "PUBLIC",
          "data": {
            "com.linkedin.digitalmedia.mediaartifact.StillImage": {
              "mediaType": "image/jpeg",
              "rawCodecSpec": {
                "name": "jpeg",
                "type": "image"
              },
              "displaySize": {
                "width": 200,
                "uom": "PX",
                "height": 200
              },
              "storageSize": {
                "width": 200,
                "height": 200
              },
              "storageAspectRatio": {
                "widthAspect": 1,
                "heightAspect": 1,
                "formatted": "1.00:1.00"
              },
              "displayAspectRatio": {
                "widthAspect": 1,
                "heightAspect": 1,
                "formatted": "1.00:1.00"
              }
            }
          },
          "identifiers": [
            {
              "identifier": "https://media-exp1.licdn.com/dms/image/C5603AQEg4EFE_HXjmA/profile-displayphoto-shrink_200_200/0/1516883336565?e=1628726400&v=beta&t=gZBfbmfNHc_rJF7JwN3ole4986DXkGALibruGQB3dOc",
              "index": 0,
              "mediaType": "image/jpeg",
              "file": "urn:li:digitalmediaFile:(urn:li:digitalmediaAsset:C5603AQEg4EFE_HXjmA,urn:li:digitalmediaMediaArtifactClass:profile-displayphoto-shrink_200_200,0)",
              "identifierType": "EXTERNAL_URL",
              "identifierExpiresInSeconds": 1628726400
            }
          ]
        },
        {
          "artifact": "urn:li:digitalmediaMediaArtifact:(urn:li:digitalmediaAsset:C5603AQEg4EFE_HXjmA,urn:li:digitalmediaMediaArtifactClass:profile-displayphoto-shrink_400_400)",
          "authorizationMethod": "PUBLIC",
          "data": {
            "com.linkedin.digitalmedia.mediaartifact.StillImage": {
              "mediaType": "image/jpeg",
              "rawCodecSpec": {
                "name": "jpeg",
                "type": "image"
              },
              "displaySize": {
                "width": 400,
                "uom": "PX",
                "height": 400
              },
              "storageSize": {
                "width": 400,
                "height": 400
              },
              "storageAspectRatio": {
                "widthAspect": 1,
                "heightAspect": 1,
                "formatted": "1.00:1.00"
              },
              "displayAspectRatio": {
                "widthAspect": 1,
                "heightAspect": 1,
                "formatted": "1.00:1.00"
              }
            }
          },
          "identifiers": [
            {
              "identifier": "https://media-exp1.licdn.com/dms/image/C5603AQEg4EFE_HXjmA/profile-displayphoto-shrink_400_400/0/1516883336565?e=1628726400&v=beta&t=47ghfPxBSsFe67qprTYqFeF_CQN0CqCOgN5_CTlhGQU",
              "index": 0,
              "mediaType": "image/jpeg",
              "file": "urn:li:digitalmediaFile:(urn:li:digitalmediaAsset:C5603AQEg4EFE_HXjmA,urn:li:digitalmediaMediaArtifactClass:profile-displayphoto-shrink_400_400,0)",
              "identifierType": "EXTERNAL_URL",
              "identifierExpiresInSeconds": 1628726400
            }
          ]
        },
        {
          "artifact": "urn:li:digitalmediaMediaArtifact:(urn:li:digitalmediaAsset:C5603AQEg4EFE_HXjmA,urn:li:digitalmediaMediaArtifactClass:profile-displayphoto-shrink_800_800)",
          "authorizationMethod": "PUBLIC",
          "data": {
            "com.linkedin.digitalmedia.mediaartifact.StillImage": {
              "mediaType": "image/jpeg",
              "rawCodecSpec": {
                "name": "jpeg",
                "type": "image"
              },
              "displaySize": {
                "width": 800,
                "uom": "PX",
                "height": 800
              },
              "storageSize": {
                "width": 800,
                "height": 800
              },
              "storageAspectRatio": {
                "widthAspect": 1,
                "heightAspect": 1,
                "formatted": "1.00:1.00"
              },
              "displayAspectRatio": {
                "widthAspect": 1,
                "heightAspect": 1,
                "formatted": "1.00:1.00"
              }
            }
          },
          "identifiers": [
            {
              "identifier": "https://media-exp1.licdn.com/dms/image/C5603AQEg4EFE_HXjmA/profile-displayphoto-shrink_800_800/0/1516883336565?e=1628726400&v=beta&t=LuQomiB4wNS0oZiD_ugNL2fDSM0BTGRRZUwRy-bkZiE",
              "index": 0,
              "mediaType": "image/jpeg",
              "file": "urn:li:digitalmediaFile:(urn:li:digitalmediaAsset:C5603AQEg4EFE_HXjmA,urn:li:digitalmediaMediaArtifactClass:profile-displayphoto-shrink_800_800,0)",
              "identifierType": "EXTERNAL_URL",
              "identifierExpiresInSeconds": 1628726400
            }
          ]
        }
      ]
    }
  },
  "location": {
    "countryCode": "gb",
    "postalCode": "London",
    "standardizedLocationUrn": "urn:li:standardizedLocationKey:(gb,London)"
  },
  "websites": [
    {
      "label": {
        "localized": {
          "en_US": "AnalystLounge.com"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      },
      "category": "OTHER",
      "url": {
        "localized": {
          "en_US": "http://www.analystlounge.com"
        },
        "preferredLocale": {
          "country": "US",
          "language": "en"
        }
      }
    }
  ],
  "lastModified": 1596111570557,
  "backgroundPicture": {
    "displayImage": "urn:li:digitalmediaAsset:C5616AQHefnY6SIRWUg",
    "created": 1464644870809,
    "lastModified": 1464644910777,
    "originalImage": "urn:li:digitalmediaAsset:C5604AQGfzX1I4a99Mg"
  }
}
'''
