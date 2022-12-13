def get_unmatched_district(district, row, matcher)

    if district.nil?
      return district
    end
  
    # Here the CITY2 field contains the district which can be matched
    if /\(?\s*U\s*\.?\s*P\s*\.?\s*\)?/.match?(district) || /\(?\s*U\s*\.?\s*T\s*\.?\s*\)?/.match?(district) || /\(?\s*M\s*\.?\s*P\s*\.?\s*\)?/.match?(district)
      return matcher.find(sanitize(row['CITY2']))
    elsif district === "KGF"
      return "KOLAR"
    elsif district === "M.P.K.V."
      return "AHMADNAGAR"
    elsif district === "PCMC"
      return "PUNE"
    elsif district === "GMC"
      return "SRINAGAR"
    elsif district === "110027"
      return "NEW DELHI"
    elsif district === "612 103"
      return "THANJAVUR"
    elsif district === "273005"
      return "GORAKHPUR"
    elsif district === "2 M"
      return "GANGANAGAR"
    else
      return district
    end
end