--[[
dotgraph - a Lua filter for pandoc to convert code blocks with class "dot" into
SVG images using dot (Graphviz). If the code block has an attribute "caption",
it is used as the caption, and the image object becomes a figure.

This does not use the mediabag and the --extract-media option, because that
doesn't play well with relative paths. Instead, the produced image is written
directly to a file.

The graphviz source code is added as an HTML comment before the image.
--]]

-- A filter operating on code blocks
function CodeBlock(elem)
	if elem.classes[1] == "dot" then
		return createDotGraph(elem)
	end
end

-- Generate an SVG image using dot, return a paragraph containing a pandoc
-- image object
function createDotGraph(elem)
	local img = pandoc.pipe("dot", {"-Tsvg"}, elem.text)
	local fname = "diagrams/" .. pandoc.sha1(img):sub(1, 7) .. ".svg"

	storeImg(fname, img)

	local imgObj = getImgObj(elem, fname)
	local comment = pandoc.RawBlock("html", "<!--\n" .. elem.text .. "\n-->")
	return pandoc.List({comment, pandoc.Para{imgObj}})
end

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
