def get_unmatched_district(district, row, matcher)

    if district.nil?
      return district
    end
  
    # Here the CITY2 field contains the district which can be matched
    if /\(?\s*U\s*\.?\s*P\s*\.?\s*\)?/.match?(district) || /\(?\s*U\s*\.?\s*T\s*\.?\s*\)?/.match?(district) || /\(?\s*M\s*\.?\s*P\s*\.?\s*\)?/.match?(district)
      return matcher.find(sanitize(row['CITY2']))
    elsif district === "KGF"
      return "Kolar"
    elsif district === "M.P.K.V."
      return "Ahmadnagar"
    elsif district === "PCMC"
      return "Pune"
    elsif district === "GMC"
      return "Srinagar"
    elsif district === "110027"
      return "New Delhi"
    elsif district === "612 103"
      return "Thanjavur"
    elsif district === "273005"
      return "Gorakhpur"
    elsif district === "2 M"
      return "Ganganagar"
    else
      return district
    end
end