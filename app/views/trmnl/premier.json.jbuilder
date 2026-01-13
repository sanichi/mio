# Convert PremierStats data for today into a JSON table (array of arrays).
# First row is the header, followed by 20 more rows (one per team).

data = PremierStats.new(Match.latest_season, Date.today)

# Build header row
header = ["Team", "P", "W", "D", "L", "F", "A", "Δ", "Pts"]
data.indicies.each do |i|
  header << (i + 1).to_s
end

# Build data rows (one per team)
rows = data.ids.map do |id|
  row = [
    data.name[id],
    data.played[id],
    data.won[id],
    data.drew[id],
    data.lost[id],
    data.for[id],
    data.against[id],
    data.diff[id],
    data.points[id]
  ]

  # Add the 10 result/fixture labels for this team
  data.indicies.each do |i|
    row << data.labels[id][i]
  end

  row
end

# Add the header to the rows.
rows.unshift header

# Return the complete table
json.table rows
