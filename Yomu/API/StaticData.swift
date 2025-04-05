//
//  StaticData.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-05.
//

import Foundation
import SwiftUI

/// A collection of all language codes used by MangaDex.
/// ### See Also
/// [Static Data](https://api.mangadex.org/docs/3-enumerations/)
@MainActor
public let languageCodeDictonary: [String: LocalizedStringKey] = [
    "en": "English",
    "sq": "Albanian",
    "ar": "Arabic",
    "az": "Azerbaijani:",
    "bn": "Bengali",
    "bg": "Bulgarian",
    "my": "Burmese",
    "ca": "Catlan",
    "zh": "Chinese (Simplified)",
    "zh-hk": "Chinese (Traditional)",
    "hr": "Croatian",
    "cs": "Czech",
    "da": "Danish",
    "nl": "Dutch",
    "eo": "Esperanto",
    "et": "Estonian",
    "tl": "Filipino",
    "fi": "Finnish",
    "fr": "French",
    "ka": "Gregorian",
    "de": "German",
    "el": "Greek",
    "he": "Hebrew",
    "hi": "Hindi",
    "hu": "Hungarian",
    "id": "Indonesian",
    "it": "Italian",
    "ja": "Japanese",
    "kk": "Kazakh",
    "ko": "Korean",
    "la": "Latin",
    "lt": "Lithuanian",
    "ms": "Malay",
    "mn": "Mongolian",
    "ne": "Nepali",
    "no": "Norwegian",
    "fa": "Persian",
    "pl": "Polish",
    "pt": "Portugese (Pt)",
    "pt-br": "Portugese (Br)",
    "ro": "Romanian",
    "ru": "Russian",
    "sr": "Serbian",
    "sk": "Slovak",
    "sl": "Slovenian",
    "es": "Spanish (Es)",
    "es-la": "Spanish (LATAM)",
    "sv": "Swedish",
    "ta": "Tamil",
    "te": "Telugu",
    "th": "Thai",
    "tr": "Turkish",
    "uk": "Ukranian",
    "vi": "Vietnamese",
    "ja-ro": "Japanese (Romanized)",
    "ko-ro": "Korean (Romanized)",
    "zh-ro": "Chinese (Romanized"
]

/// A collection of strings
///
/// Values such as ``Manga/title``, ``Manga/altTitles``, ``Manga/description`` may be provided in multiple languages. ``LocalizedLanguage`` allows for these
/// values to be found with their respective ``languageCodeDictonary``.
///
/// ### See Also
/// [Static Data](https://api.mangadex.org/docs/3-enumerations/)
struct LocalizedLanguage: Codable {
    let en: String?
    let sq: String?
    let ar: String?
    let az: String?
    let bn: String?
    let bg: String?
    let my: String?
    let ca: String?
    let cnSimplified: String?
    let cnTraditional: String?
    let hr: String?
    let cs: String?
    let da: String?
    let nl: String?
    let eo: String?
    let et: String?
    let tl: String?
    let fi: String?
    let fr: String?
    let ka: String?
    let de: String?
    let el: String?
    let he: String?
    let hi: String?
    let hu: String?
    let id: String?
    let it: String?
    let ja: String?
    let kk: String?
    let ko: String?
    let la: String?
    let lt: String?
    let ms: String?
    let mn: String?
    let ne: String?
    let no: String?
    let fa: String?
    let pl: String?
    let ptPortugal: String?
    let ptBrazil: String?
    let ro: String?
    let ru: String?
    let sr: String?
    let sk: String?
    let sl: String?
    let esSpain: String?
    let esLATAM: String?
    let sv: String?
    let ta: String?
    let te: String?
    let th: String?
    let tr: String?
    let uk: String?
    let vi: String?
    let jaRomanized: String?
    let koRomanized: String?
    let zhRomanized: String?
}

extension LocalizedLanguage {
    public enum CodingKeys: String, CodingKey {
        case en
        case sq
        case ar
        case az
        case bn
        case bg
        case my
        case ca
        case cnSimplified = "zh"
        case cnTraditional = "zh-hk"
        case hr
        case cs
        case da
        case nl
        case eo
        case et
        case tl
        case fi
        case fr
        case ka
        case de
        case el
        case he
        case hi
        case hu
        case id
        case it
        case ja
        case kk
        case ko
        case la
        case lt
        case ms
        case mn
        case ne
        case no
        case fa
        case pl
        case ptPortugal = "pt"
        case ptBrazil = "pt-br"
        case ro
        case ru
        case sr
        case sk
        case sl
        case esSpain = "es"
        case esLATAM = "es-la"
        case sv
        case ta
        case te
        case th
        case tr
        case uk
        case vi
        case jaRomanized = "ja-ro"
        case koRomanized = "ko-ro"
        case zhRomanized = "zh-ro"
    }
}

/// A collection of links for manga trackers, and official sources
///
/// MangaDex's Api returns different formats for different services, URL templates documentation is provided within ``MangaLink``.
///
/// ### See Also
/// [Static Data](https://api.mangadex.org/docs/3-enumerations/)
public struct MangaLink: Codable, Equatable, Hashable, Sendable {
    /// anilist: stored as id
    /// ### Format
    /// https://anilist.co/manga/{id}
    let al: String?
    
    /// animeplanet: stored as slug
    /// ### Format
    /// https://www.anime-planet.com/{slug}
    let ap: String?
    
    /// bookwalker: stored as series
    /// ## Format
    /// https://bookwalker.jp/{series]
    let bw: String?
    
    /// mangaupdates: stored as id
    /// ## Format
    /// https://www.mangaupdates.com/series/{id}
    let mu: String?
    
    /// novelupdates: stored as slug
    /// ## Format
    /// https://www.novelupdates.com/series/{slug}
    let nu: String?
    
    /// kitsu: stored as id or slug
    /// ## Format
    /// https://kitsu.app/manga/{id or slug]
    let kt: String?
    
    /// amazon: stored as full URL
    /// ## Format
    /// {url}
    let amz: String?
    
    /// ebookjapan: stored as full URL
    /// ## Format
    /// {url}
    let ebj: String?
    
    /// myanimelist: stored as id
    /// ## Format
    /// https://myanimelist.net/manga/{id}
    let mal: String?
    
    /// CDJapan: stored as full URL
    /// ## Format
    /// {url}
    let cdj: String?
    
    /// Official raw: stored as full URL
    /// ## Format
    /// {url}
    let raw: String?
    
    /// Official English translation: stored as full url
    /// ## Format
    /// {url}
    let engtl: String?
}

/// An intended demographic of a manga.
/// ### See Also
/// [Static Data](https://api.mangadex.org/docs/3-enumerations/)
///
/// [Wikipedia: shounen](https://en.wikipedia.org/wiki/Shōnen_manga)
///
/// [Wikipedia: shoujo](https://en.wikipedia.org/wiki/Shōjo_manga)
///
/// [Wikipedia: josei](https://en.wikipedia.org/wiki/Josei_manga)
///
/// [Wikipedia: seinen](https://en.wikipedia.org/wiki/Seinen_manga)
@frozen
public enum Demographic: String, Codable, Sendable {
    /// Indicates that the target audience of a given manga is adolescent boys, and young men.
    case shounen
    
    /// Indicates that the target audince of a given manga is adolescent girls, and yound women.
    case shoujo
    
    /// Indicates that the target audeince of a given manga is adult women.
    case josei
    
    /// Indicates that the target audience of a given manga is young adults, and adult men.
    case seinen
}

/// The current publication status of a manga.
/// ### See Also
/// [Static Data](https://api.mangadex.org/docs/3-enumerations/)
@frozen
public enum Status: String, Codable, Sendable {
    /// Indicates that publication of a manga is still in progress.
    case ongoing
    
    /// Indicates that publication of a manga has been completed
    case completed
    
    /// Indicates that publication of a manga is currently paused, but will resume.
    case hiatus
    
    /// Indicates that publication of a manga has been cancelled.
    case cancelled
}

/// A manga's reading status for a user
/// ### See Also
/// [Static Data](https://api.mangadex.org/docs/3-enumerations/)
@frozen
public enum ReadingStatus: String, Codable, Sendable {
    /// Indicates a user is currently reading this manga.
    case reading = "reading"
    
    /// Indicates a user has currently paused reading this manga.
    case on_hold = "on_hold"
    
    /// Indicates a user plans to  read this manga.
    case plan_to_read = "plan_to_read"
    
    /// Indicates a user will not continue reading this manga.
    case dropped = "dropped"
    
    /// Indicates a user is currently re-reading this manga.
    case re_reading = "re_rereading"
    
    /// Indicates a user has completed reading this manga.
    case completed = "completed"
}

/// A content rating for a given manga.
@frozen
public enum Rating: Codable, Sendable {
    /// Includes no nudity, and makes to direct references to any R18 content.
    case safe
    
    /// Includes no nudity, may include references to sexual themes or other R18 content.
    /// > Important:
    ///  This content may not be fit for minors, and may not be sutable for certain environments.
    case suggestive
    
    /// Includes no full nudity, includes strong implications of nudity or other sexual and R18 themes.
    /// > Important:
    ///  This content is not fit for minors,  and may not be sutable for certain environments.
    case erotica
    
    /// Includes R18 sexual content.
    /// > Important:
    ///  This content is not fit for minors, and may not be sutable for certain environments.
    case pornographic
    
    var value: [URLQueryItem] {
        switch self {
        case .safe:
            return [URLQueryItem(name: "contentRating[]", value: "safe")]
        case .suggestive:
            return [URLQueryItem(name: "contentRating[]", value: "safe"), URLQueryItem(name: "contentRating[]", value: "suggestive")]
        case .erotica:
            return [URLQueryItem(name: "contentRating[]", value: "safe"), URLQueryItem(name: "contentRating[]", value: "suggestive"), URLQueryItem(name: "contentRating[]", value: "erotica")]
        case .pornographic:
            return [URLQueryItem(name: "contentRating[]", value: "safe"), URLQueryItem(name: "contentRating[]", value: "suggestive"), URLQueryItem(name: "contentRating[]", value: "erotica"), URLQueryItem(name: "contentRating[]", value: "pornographic")]
        }
    }
}

/// A brief description of a relationship
public enum RelationshipType: Codable, Sendable {
    /// A related ``Manga`` id or value.
    case manga
    
    /// A related ``Chapter`` id or value.
    case chapter
    
    /// A related ``Cover`` id or value.
    case cover_art
    
    /// A related ``Author`` id or value.
    case author
    
    /// A related ``Author`` id or value.
    case artist
    
    /// A related ``ScanlationGroup`` id or value.
    case scanlation_group
    
    /// A related ``Tag`` id or value.
    case tag
    
    /// A related ``User`` id or value.
    case user
    
    /// A related custom list `UUID`
    case custom_list
}

/// A brief description of a manga related to a given manga.
public enum MangaRelated: String, Codable, Sendable {
    /// A black and white version of a full color manga.
    case monochrome
    
    /// A full color version of a non-colored manga.
    case colored
    
    /// A version of this manga released before its serialization
    case preserialization
    
    /// A version of this manga released during or after its serialization
    case serialization
    
    /// A manga that details a story set before this manga.
    case prequel
    
    /// A manga that details a story set after this manga.
    case sequel
    
    /// A manga that occurs in the same universe, and follows the main cast of characters.
    case main_story
    
    /// A manga that occurs in the same universe and expands on a subplot of the main story.
    case side_story
    
    /// A manga adapted from a different meduim such as a web or light novel.
    case adapted_from
    
    /// A manga that occurs in the same universe often starring side characters from the main story.
    case spin_off
    
    /// A manga that uses of adapts elements from another manga.
    case based_on
    
    /// A derivate work uses the setting and characters from a specific manga.
    /// ### See Also
    /// [Wikipedia: doujinshi](https://en.wikipedia.org/wiki/Doujinshi)
    case doujinshi
    
    /// A manga that is written by the same author, often shares themes with other manga in the same franchise.
    case same_franchise
    
    /// A manga that takes place in the same universe as the main story, but may be completely unrelated otherwise.
    case shared_universe
    
    /// An alterate plot of a manga's main story.
    case alternate_story
    
    /// An alternate version of a manga, its plot is identical to other versions.
    case alternate_version
}

/// The order for a collection.
///
/// The MangaDex API can return collections in both ascending and descending order.
///  A collections sort is determined by its endpoint. For more information see [MangaDex API](https://api.mangadex.org/docs/redoc.html)
@frozen
public enum Order: String {
    /// Ascending order, smallest or newest first.
    case asc = "asc"
    
    /// Descending order, largest or oldest first.
    case desc = "desc"
}

/// The available base URLs for making calls to the MangaDexAPI.
@frozen
public enum Server: String {
    /// The base URL of almost every endpoint, use this unless expliciity stated otherwise.
    case standard = "api.mangadex.org"
    
    /// This base URL is only to be used for reporting the sucess or failiure of fetching chapter images.
    case network = "api.mangadex.network"
    
    /// This base URL is only used for initial authentication to obtain a users OAuth token.
    ///
    /// - Important: Do not use this URL of OAuth authenticated API calls, authenticated requests should be done with the
    ///              with the ``Server/standard`` base url and pass the access token in the requests authorization header.
    case auth = "auth.mangadex.org"
}

/// The logical operator for how tags will be included in a search query.
@frozen
public enum IncludedTagsMode: String {
    /// Will only return manga with all included tags.
    case and = "AND"
    
    /// Will return manga with any of the included tags.
    case or = "OR"
}

/// The logical operator for how tags will be excluede in a search query.
@frozen
public enum ExcludedTagsMode: String {
    /// Will only filter out manga with all excluded tags.
    case and = "AND"
    
    /// Will filter out manga with any of the excluded tags.
    case or = "OR"
}
