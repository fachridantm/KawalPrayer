import SwiftUI

public enum ColorToken {

    // MARK: - Hex Initializer Helper

    public static func fromHex(_ hex: UInt32, alpha: Double = 1.0) -> Color {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        return Color(red: r, green: g, blue: b, opacity: alpha)
    }

    // MARK: - Grey & Borders

    public static let GreyBorder       = Color.white.opacity(0.30)
    public static let GreyBackground   = Color.white.opacity(0.10)

    // MARK: - Input & Text

    public static let InputContainer   = fromHex(0xF9FAFB)
    public static let InputBorder      = fromHex(0xDADCE0)
    public static let TextSecondary    = fromHex(0x4B5563)

    // MARK: - Google Blue Palette

    public static let Blue             = fromHex(0x4285F4)
    public static let BlueHalftone     = fromHex(0x57CAFF)
    public static let BluePastel       = fromHex(0xC3ECF6)

    public static let Blue10           = fromHex(0xE6F3FF)
    public static let Blue20           = fromHex(0xB3DBFF)
    public static let Blue30           = fromHex(0x80C4FF)
    public static let Blue40           = fromHex(0x33A0FF)
    public static let Blue50           = fromHex(0x0088FF)
    public static let Blue60           = fromHex(0x006DCC)
    public static let Blue70           = fromHex(0x005FB3)
    public static let Blue80           = fromHex(0x005299)
    public static let Blue90           = fromHex(0x003666)

    // MARK: - Google Green Palette

    public static let Green            = fromHex(0x34A853)
    public static let GreenHalftone    = fromHex(0x5CDB6D)
    public static let GreenPastel      = fromHex(0xCCF6C5)

    public static let Green10          = fromHex(0xE6EEE8)
    public static let Green20          = fromHex(0xB3CDBA)
    public static let Green30          = fromHex(0x80AC8D)
    public static let Green40          = fromHex(0x338B50)
    public static let Green50          = fromHex(0x00591A)
    public static let Green60          = fromHex(0x005017)
    public static let Green70          = fromHex(0x004715)
    public static let Green80          = fromHex(0x003E12)
    public static let Green90          = fromHex(0x003510)

    // MARK: - Google Yellow Palette

    public static let Yellow           = fromHex(0xF9AB00)
    public static let YellowHalftone   = fromHex(0xFFD427)
    public static let YellowPastel     = fromHex(0xFFE7A5)

    public static let Yellow10         = fromHex(0xFFFFFBEE)
    public static let Yellow20         = fromHex(0xFFFFECB7)
    public static let Yellow30         = fromHex(0xFFFFD96F)
    public static let Yellow40         = fromHex(0xFFFFCC3F)
    public static let Yellow50         = fromHex(0xFFFFBF0F)
    public static let Yellow60         = fromHex(0xE6AC0E)
    public static let Yellow70         = fromHex(0xCC990C)
    public static let Yellow80         = fromHex(0xB3860B)
    public static let Yellow90         = fromHex(0x997309)

    // MARK: - Google Red Palette

    public static let Red              = fromHex(0xEA4335)
    public static let RedHalftone      = fromHex(0xFFFF7DAF)
    public static let RedPastel        = fromHex(0xF8D8D8)

    public static let Red10            = fromHex(0xFBE9EA)
    public static let Red20            = fromHex(0xF4BDBF)
    public static let Red30            = fromHex(0xED9194)
    public static let Red40            = fromHex(0xE24F54)
    public static let Red50            = fromHex(0xDB2329)
    public static let Red60            = fromHex(0xAF1C21)
    public static let Red70            = fromHex(0x99191D)
    public static let Red80            = fromHex(0x831519)
    public static let Red90            = fromHex(0x6E1215)

    // MARK: - Neutrals: LightGrey

    public static let LightGrey10      = fromHex(0xFAFAFA)
    public static let LightGrey20      = fromHex(0xF5F5F5)
    public static let LightGrey30      = fromHex(0xF0F0F0) // GDG Brand Guide
    public static let LightGrey40      = fromHex(0xEBEBEB)
    public static let LightGrey50      = fromHex(0xE6E6E6)
    public static let LightGrey60      = fromHex(0xE0E0E0)
    public static let LightGrey70      = fromHex(0xDBDBDB)
    public static let LightGrey80      = fromHex(0xD6D6D6)
    public static let LightGrey90      = fromHex(0xCCCCCC)

    // MARK: - Neutrals: DarkGrey

    public static let DarkGrey10       = fromHex(0x1E1E1E) // GDG Brand Guide
    public static let DarkGrey20       = fromHex(0x262626)
    public static let DarkGrey30       = fromHex(0x333333)
    public static let DarkGrey40       = fromHex(0x404040)
    public static let DarkGrey50       = fromHex(0x4D4D4D)
    public static let DarkGrey60       = fromHex(0x595959)
    public static let DarkGrey70       = fromHex(0x666666)
    public static let DarkGrey80       = fromHex(0x737373)
    public static let DarkGrey90       = fromHex(0x808080)

    // MARK: - Neutrals: Black

    public static let Black10          = fromHex(0xE8E8E8)
    public static let Black20          = fromHex(0xD1D1D1)
    public static let Black30          = fromHex(0xBABABA)
    public static let Black40          = fromHex(0xA3A3A3)
    public static let Black50          = fromHex(0x8D8D8D)
    public static let Black60          = fromHex(0x767676)
    public static let Black70          = fromHex(0x5F5F5F)
    public static let Black80          = fromHex(0x484848)
    public static let Black90          = fromHex(0x1A1A1A)

    // MARK: - Transparencies

    public static let WhiteTransparent10 = Color.white.opacity(FloatToken.PERCENT_10)
    public static let WhiteTransparent20 = Color.white.opacity(FloatToken.PERCENT_20)
    public static let WhiteTransparent30 = Color.white.opacity(FloatToken.PERCENT_30)
    public static let WhiteTransparent40 = Color.white.opacity(FloatToken.PERCENT_40)
    public static let WhiteTransparent50 = Color.white.opacity(FloatToken.PERCENT_50)
    public static let WhiteTransparent60 = Color.white.opacity(FloatToken.PERCENT_60)
    public static let WhiteTransparent70 = Color.white.opacity(FloatToken.PERCENT_70)
    public static let WhiteTransparent80 = Color.white.opacity(FloatToken.PERCENT_80)
    public static let WhiteTransparent90 = Color.white.opacity(FloatToken.PERCENT_90)

    public static let BlackTransparent10 = fromHex(0x1A1A1A, alpha: FloatToken.PERCENT_10)
    public static let BlackTransparent20 = fromHex(0x1A1A1A, alpha: FloatToken.PERCENT_20)
    public static let BlackTransparent30 = fromHex(0x1A1A1A, alpha: FloatToken.PERCENT_30)
    public static let BlackTransparent40 = fromHex(0x1A1A1A, alpha: FloatToken.PERCENT_40)
    public static let BlackTransparent50 = fromHex(0x1A1A1A, alpha: FloatToken.PERCENT_50)
    public static let BlackTransparent60 = fromHex(0x1A1A1A, alpha: FloatToken.PERCENT_60)
    public static let BlackTransparent70 = fromHex(0x1A1A1A, alpha: FloatToken.PERCENT_70)
    public static let BlackTransparent80 = fromHex(0x1A1A1A, alpha: FloatToken.PERCENT_80)
    public static let BlackTransparent90 = fromHex(0x1A1A1A, alpha: FloatToken.PERCENT_90)
}
