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
    /// An English value.
    let en: String?
    
    /// An Albainian value.
    let sq: String?
    
    /// An Arabic value.
    let ar: String?
    
    /// An Azerbaijani value.
    let az: String?
    
    /// A Bengali value.
    let bn: String?
    
    /// A Bulgarian value.
    let bg: String?
    
    /// A Burmese value.
    let my: String?
    
    /// A Catalan or Valencian value.
    let ca: String?
    
    /// A Simplified Chinese value.
    let cnSimplified: String?
    
    /// A Traditional Chinese value.
    let cnTraditional: String?
    
    /// A Croatian value.
    let hr: String?
    
    /// A Czech value.
    let cs: String?
    
    /// A Danish value.
    let da: String?
    
    /// A Dutch or Flemish value.
    let nl: String?
    
    /// An Espertano value.
    let eo: String?
    
    /// An Estonian value.
    let et: String?
    
    /// A Tagalog value.
    let tl: String?
    
    /// A Finnish value.
    let fi: String?
    
    /// A French value.
    let fr: String?
    
    /// A Gregorian value.
    let ka: String?
    
    /// A German value.
    let de: String?
    
    /// A Greek value.
    let el: String?
    
    /// A Hebrew value.
    let he: String?
    
    /// A Hindi value.
    let hi: String?
    
    /// A Hungarian value.
    let hu: String?
    
    /// A Indonesian value.
    let id: String?
    
    /// An Italian value.
    let it: String?
    
    /// A Japanese value.
    let ja: String?
    
    /// A Kazakh value.
    let kk: String?
    
    /// A Korean value.
    let ko: String?
    
    /// A Latin value.
    let la: String?
    
    /// A Lithuanian value.
    let lt: String?
    
    /// A Malay value.
    let ms: String?
    
    /// A Mongolian value.
    let mn: String?
    
    /// A Nepali value.
    let ne: String?
    
    /// A Norwegian value.
    let no: String?
    
    /// A Persian value.
    let fa: String?
    
    /// A Polish value.
    let pl: String?
    
    /// A Portigal Portuguese value.
    let ptPortugal: String?
    
    /// A Brazillian Portuguese value.
    let ptBrazil: String?
    
    /// A Romainian, Moldavian, or Moldovan value.
    let ro: String?
    
    /// A Russian value.
    let ru: String?
    
    /// A Serbian value.
    let sr: String?
    
    /// A Slovak value.
    let sk: String?
    
    /// A Solvenian value.
    let sl: String?
    
    /// A Spain Spanish value.
    let esSpain: String?
    
    /// A Latin American Spanish value.
    let esLATAM: String?
    
    /// A Swedish value.
    let sv: String?
    
    /// A Tamil value.
    let ta: String?
    
    /// A Telugu value.
    let te: String?
    
    /// A Thai value.
    let th: String?
    
    /// A Turksih value.
    let tr: String?
    
    /// A Ukrainian value.
    let uk: String?
    
    /// A Vietnamese value.
    let vi: String?
    
    /// A Romanized Japanese value.
    let jaRomanized: String?
    
    /// A Romanized Korean value.
    let koRomanized: String?
    
    /// A Romanized Chinese value.
    let zhRomanized: String?
}

extension LocalizedLanguage {
    public enum CodingKeys: String, CodingKey {
        /// English
        case en
        
        /// Albainian
        case sq
        
        /// Arabic
        case ar
        
        /// Azerbaijani
        case az
        
        /// Bengali
        case bn
        
        /// Bulgarian
        case bg
        
        /// Burmese
        case my
        
        /// Catalan or Valencian
        case ca
        
        /// Simplified Chinese
        case cnSimplified = "zh"
        
        /// Traditional Chinese
        case cnTraditional = "zh-hk"
        
        /// Croatian.
        case hr
        
        /// Czech
        case cs
        
        /// Danish
        case da
        
        /// Dutch or Flemish
        case nl
        
        /// Espertano
        case eo
        
        /// Estonian
        case et
        
        /// Tagalog
        case tl
        
        /// Finnish
        case fi
        
        /// French
        case fr
        
        /// Gregorian
        case ka
        
        /// German
        case de
        
        /// Greek
        case el
        
        /// Hebrew
        case he
        
        /// Hindi
        case hi
        
        /// Hungarian
        case hu
        
        /// Indonesian
        case id
        
        /// Italian
        case it
        
        /// Japanese
        case ja
        
        /// Kazakh
        case kk
        
        /// Korean
        case ko
        
        /// Latin
        case la
        
        /// Lithuanian
        case lt
        
        /// Malay
        case ms
        
        /// Mongolian
        case mn
        
        /// Nepali
        case ne
        
        /// Norwegian
        case no
        
        /// Persian
        case fa
        
        /// Polish
        case pl
        
        /// Portuguese
        case ptPortugal = "pt"
        
        /// Brazillian Portuguese
        case ptBrazil = "pt-br"
        
        /// Romainian, Moldavian, or Moldovan
        case ro
        
        /// Russian
        case ru
        
        /// Serbian
        case sr
        
        /// Slovak
        case sk
        
        /// Slovenian
        case sl
        
        /// Spanish
        case esSpain = "es"
        
        /// Latin American Spanish
        case esLATAM = "es-la"
        
        /// Swedish
        case sv
        
        /// Tamil
        case ta
        
        /// Telugu
        case te
        
        /// Thai
        case th
        
        /// Turkish
        case tr
        
        /// Ukrainian
        case uk
        
        /// Vietnamese
        case vi
        
        /// Romanized Japanese
        case jaRomanized = "ja-ro"
        
        /// Romanized Korean
        case koRomanized = "ko-ro"
        
        /// Romanized Chinese
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

extension MangaLink {
    /// Returns the complete URL for a manga on [anilist.co](https://anilist.co).
    var anilistURL: URL? {
        if let id = self.al { return URL(string: "https://anilist.co/manga/\(id)") }
        return nil
    }
    
    /// Returns the complete URL for a manga on [anime-planet.com](https://www.anime-planet.com).
    var animePlanetURL: URL? {
        if let slug = self.ap { return URL(string: "https://www.anime-planet.com/\(slug)") }
        return nil
    }
    
    /// Returns the complete URL for a manga on [bookwalker.jp](https://bookwalker.jp).
    var bookWalkerURL: URL? {
        if let series = self.bw { return URL(string: "https://bookwalker.jp/\(series)") }
        return nil
    }
    
    /// Returns the complete URL for a manga on [mangaupdates.com](https://mangaupdates.com).
    var mangaUpdatesURL: URL? {
        if let id = self.mu { return URL(string: "https://mangaupdates.com/series/\(id)") }
        return nil
    }
    
    /// Returns the complete URL for a manga on [novelupdates.com](https://novelupdates.com).
    var novelUpdatesURL: URL? {
        if let slug = self.nu { return URL(string: "https://novelupdates.com/series/\(slug)") }
        return nil
    }
    
    /// Returns the complete URL for a manga on [kitsu.app](https://kitsu.app).
    var kitsuURL: URL? {
        if let idOrSlug = self.kt { return URL(string: "https://kitsu.app/manga/\(idOrSlug)") }
        return nil
    }
    
    /// Returns the complete URL for a manga on [amazon](https://amazon.com).
    var amazonURL: URL? {
        if let urlString = self.amz { return URL(string: urlString) }
        return nil
    }
    
    /// Returns the complete URL for a manga on [ebookjapan.](https://ebookjapan.yahoo.co.jp).
    var eBookJapanURL: URL? {
        if let urlString = self.ebj { return URL(string: urlString) }
        return nil
    }
    
    /// Returns the complete URL for a manga on [myanimelist.net](https://myanimelist.net/manga).
    var myAnimeListURL: URL? {
        if let id = self.mal { return URL(string: "https://myanimelist.net/manga/\(id)")}
        return nil
    }
    
    /// Returns the complete URL for a manga on [cdjapan.co](https://www.cdjapan.co.jp).
    var cdJapanURL: URL? {
        if let urlString = self.cdj { return URL(string: urlString) }
        return nil
    }
    
    /// Returns the complete URL for the webpage where a manga's official raw can be found.
    var officalRawURL: URL? {
        if let urlString = self.raw { return URL(string: urlString) }
        return nil
    }
    
    /// Returns the complete URL for the webpage where a manga's official english translation can be found.
    var englishTranslationURL: URL? {
        if let urlString = self.engtl { return URL(string: urlString) }
        return nil
    }
}

extension MangaLink {
    /// Gets all the available links for a manga.
    ///
    /// - Returns: all non nil links.
    func getAvailableLinks() -> [URL] {
        [self.anilistURL, self.animePlanetURL, self.bookWalkerURL, self.mangaUpdatesURL, self.mangaUpdatesURL, self.novelUpdatesURL, self.kitsuURL, self.amazonURL, self.eBookJapanURL, self.myAnimeListURL, self.cdJapanURL, self.officalRawURL, self.englishTranslationURL].compactMap( { $0 })
    }
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
    /// Indicateds there is no reading status.
    case none = "none"
    
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
public enum Rating: String, Codable, Sendable {
    /// Includes no nudity, and makes to direct references to any R18 content.
    case safe = "safe"
    
    /// Includes no nudity, may include references to sexual themes or other R18 content.
    /// > Important:
    ///  This content may not be fit for minors, and may not be sutable for certain environments.
    case suggestive = "suggestive"
    
    /// Includes no full nudity, includes strong implications of nudity or other sexual and R18 themes.
    /// > Important:
    ///  This content is not fit for minors,  and may not be sutable for certain environments.
    case erotica = "erotica"
    
    /// Includes R18 sexual content.
    /// > Important:
    ///  This content is not fit for minors, and may not be sutable for certain environments.
    case pornographic = "pornographic"
    
    /// Returns the list of query items associated with a specific rating value.
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
