// Common definitions and functions
// Warning! Changes to these can break existing tests

let _line1 = "version 1.0"
let _line2 = "[\"companyUuid1\",1.01,2.02,[\"tagUuid1\",\"tagUuid2\"]]"
let _line3 = "[\"companyUuid2\",3.03,4.04,[\"tagUuid2\",\"tagUuid3\"]]"

func _makeDownloadFileString() -> String {
    return """
    \(_line1)
    \(_line2)
    \(_line3)
    """
}
