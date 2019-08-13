import Foundation

/// Enumeration of the different types of content hosted by the workfinder server
/// that may be displayed by the Workfinder apps
public enum F4SContentType: String, Codable {
    case about = "about-workfinder"
    case recommendations
    case faq
    case terms
    case voucher
    case consent
    case company
}

/// Represents the content of a url hosted by the Workfinder server for use by the client
public struct F4SContentDescriptor : Codable {
    /// The title of the content (suitable for presentation)
    public var title: String
    /// A value representing the slug
    public var slug: F4SContentType
    /// The url
    public var url: String?
    /// Initialises a new instance
    ///
    /// - Parameters:
    ///   - title: title of the content
    ///   - slug: the slug
    ///   - url: the url
    public init(title: String = "", slug: F4SContentType = .about, url: String? = "") {
        self.title = title
        self.slug = slug
        self.url = url
    }
}
