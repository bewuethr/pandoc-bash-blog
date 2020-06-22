--[[
dotgraph - a Lua filter for pandoc to convert code blocks with class "dot" into
SVG images using dot (Graphviz). If the code block has an attribute "caption",
it is used as the caption, and the image object becomes a figure.

If the code block has class "includeSource" (or "include-source"), a comment
containing the dot source is included before the diagram figure.

This does not use the mediabag and the --extract-media option, because that
doesn't play well with relative paths. Instead, the produced image is written
directly to a file.
--]]

-- A filter operating on code blocks
function CodeBlock(elem)
	if elem.classes:includes("dot") then
		return createDotGraph(elem)
	end
end

-- Generate an SVG image using dot, return a list containing source code
-- comment (if desired) and a pandoc image object
function createDotGraph(elem)
	local success, img = pcall(pandoc.pipe, "dot", {"-Tsvg"}, elem.text)
	if not success then
		io.stderr:write(tostring(img) .. '\n')
		error("dot graph generation failed")
	end

	local fname = "diagrams/" .. pandoc.sha1(img):sub(1, 7) .. ".svg"

	storeImg(fname, img)

	retList = pandoc.List()
	if elem.classes:includes("includeSource") or elem.classes:includes("include-source") then
		local comment = pandoc.RawBlock("html", "<!--\n" .. elem.text .. "\n-->")
		retList:extend({comment})
	end

	local imgObj = getImgObj(elem, fname)
	retList:extend({pandoc.Para{imgObj}})

	return retList
end

-- Store the image to a file in the artifacts subdirectory
function storeImg(fname, img)
	local f = assert(io.open("artifacts/" .. fname, "w"))
	f:write(img)
	f:flush()
	f:close()
end

-- Return a pandoc image object
function getImgObj(elem, fname)
	if not elem.attributes.caption then
		return pandoc.Image("", fname)
	end

	-- Trigger a full-blown figure
	local enableCaption = "fig:"
	return pandoc.Image(elem.attributes.caption, fname, enableCaption)
end
