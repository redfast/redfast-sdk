' Copyright (C) 2020 Redfast Inc - All Rights Reserved
'
' It can not be copied and/or distributed without the express
' permission of Redfast Inc

sub init()
    m.root = m.top.findNode("root")
    m.thumbnail = m.top.findNode("thumbnail")
    m.title = m.top.findNode("title")
    m.description = m.top.findNode("description")
    m.border = m.top.findNode("border")
    
    m.titleRowHeight = 36
    m.descriptionRowHeight = 60
    
    m.title.height = m.titleRowHeight
    m.description.height = m.descriptionRowHeight
end sub
    
sub setContent()
    if m.top.content.HDPosterUrl <> invalid
        m.thumbnail.uri = m.top.content.HDPosterUrl
    else if m.top.content.SDPosterUrl <> invalid
        m.thumbnail.uri = m.top.content.SDPosterUrl
    else if m.top.content.FHDPosterUrl <> invalid
        m.thumbnail.uri = m.top.content.FHDPosterUrl
    end if
    m.description.text = m.top.content.description
    m.title.text = m.top.content.title
end sub

sub setHeight()
    if m.top.content = invalid
        return
    end if
    imageHeight = m.top.height - m.titleRowHeight - m.descriptionRowHeight
    imageWidth = imageHeight
    if m.top.content.ContentType = 1
        imageWidth = cint(2.0 * imageHeight / 3.0)
    else
        imageWidth = cint(4.0 * imageHeight / 3.0)
    end if
    
    m.root.height = m.top.height
    m.root.width = imageWidth + 2
    m.border.height = m.top.height
    m.border.width = imageWidth + 2
    m.thumbnail.height = imageHeight
    m.thumbnail.width = imageWidth
    m.title.width = imageWidth
    m.title.translation = [0, imageHeight]
    m.description.width = imageWidth
    m.description.translation = [0, imageHeight + m.titleRowHeight]
end sub

sub setHighlight()
    m.border.visible = m.top.highlight
end sub
