//
//  StaticData.swift
//  Yomu
//
//  Created by Andrew Joe on 2024-06-05.
//

import Foundation
import SwiftUI

let languageCodeDictonary: [String: LocalizedStringKey] = [
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

struct MangaLink: Codable {
    let al: String? // anilist, stored as id
    let ap: String? // animeplanet, stored as slug
    let bw: String? // bw, stored as series/
    let mu: String? // mangaupdates, stored as id
    let nu: String? // novelupdates, stored as slug
    let kt: String? // kitsu.io, stored as int id or slug
    let amz: String? // amazon, stored as full URL
    let ebj: String? // ebookjapan, stored as full URL
    let mal: String? // myanimelist, stored as id
    let cdj: String? // CDJapan, stored as full URL
    let raw: String? // stored as full URL, untranslated stuff URL
    let engtl: String? // stored as full URL, official english licened URL
}

enum Demographic: String, Codable {
    case shounen
    case shoujo
    case josei
    case seinen
}

enum Status: String, Codable {
    case ongoing
    case completed
    case hiatus
    case cancelled
}

enum Rating: String, Codable {
    case safe
    case suggestive
    case erotica
    case pornographic
}

enum RelationshipType: Codable {
    case manga
    case chapter
    case cover_art
    case author
    case artist
    case scanlation_group
    case tag
    case user
    case custom_list
}

enum MangaRelated: String, Codable {
    case monochrome
    case colored
    case preserialization
    case serialization
    case prequel
    case sequel
    case main_story
    case side_story
    case adapted_from
    case spin_off
    case based_on
    case doujinshi
    case same_franchise
    case shared_universe
    case alternate_story
    case alternate_version
}
