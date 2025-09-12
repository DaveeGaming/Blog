local pprint = require("plugins.pprint")
local json = require("plugins.json")

local dump_file = io.open("dump/dump.json", "r")

if dump_file == nil then
    error("Invalid path to dump file, or json dump is missing, check the soupault logs")
end

local json = json.decode(dump_file:read("a"))

pprint(json)

local feed = io.open("build/feed.xml", "w+")
feed:write('<?xml version="1.0" encoding="utf-8"?>\n')
feed:write('<feed xmlns="http://www.w3.org/2005/Atom">\n\n')

feed:write('<title>epimoni dev feed</title>\n')
feed:write('<link href="https://epimoni.dev"/>\n')
feed:write('<updated>'.. os.date("%Y-%m-%dT%H:%M:%SZ") ..'</updated>\n')
feed:write('<author>\n')
feed:write('\t<name>epimoni</name>\n')
feed:write('</author>\n')
feed:write('<id>https://epimoni.dev</id>\n')
feed:write('\n')

for k,entry in pairs(json) do
    print(k, entry["nav_path"][1])

    feed:write('<entry>\n')
    feed:write('\t<title>'..entry["title"]..'</title>\n')
    feed:write('\t<link href="https://epimoni.dev'..entry["url"]..'" />\n')
    feed:write('\t<published>'..entry["date"]..'</published>\n')
    feed:write('\t<summary>'..entry["excerpt"]..'</summary>\n')

    local file = io.popen("stat -c %Y " .. entry["page_file"])
    local last_modified_timestamp = file:read()

    feed:write('\t<updated>'..os.date("%Y-%m-%dT%H:%M:%SZ", last_modified_timestamp)..'</updated>\n')
    feed:write('\t<category>'..entry["nav_path"][1]..'</category>\n')
    feed:write('\t<id>https://epimoni.dev</id>\n')
    feed:write('</entry>\n\n')
end

feed:write('</feed>')
feed:close()