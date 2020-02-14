' Copyright (C) 2020 Redfast Inc - All Rights Reserved
'
' It can not be copied and/or distributed without the express
' permission of Redfast Inc

sub init()
    m.root = m.top.findNode("root")
    m.shadow = m.top.findNode("shadow")
    m.title = m.top.findNode("title")
    m.contentRoot = m.top.findNode("contentRoot")

    m.shadowSize = 2
    m.rootPaddingVert = 10
    m.rootPaddingHorz = 20
    m.titleRowHeight = 45
    m.cardSpace = 20
    m.xOffset = 0
    m.inAnimation = false
    m.top.history = {xOffset: 0, currentItem: -1}
end sub

sub setContent()
    m.title.text = m.top.content.title
    m.xOffset = 0
    setSize()
end sub

sub setSize()
    if m.top.width > 0 and m.top.height > 0 and m.top.content <> invalid
        m.shadow.height = m.top.height
        m.shadow.width = m.top.width
        m.root.height = m.top.height - m.shadowSize * 2
        m.root.width = m.top.width -  m.shadowSize * 2
        m.root.translation = [m.shadowSize, m.shadowSize]
        m.title.height = m.titleRowHeight
        m.title.width = m.root.width - m.rootPaddingHorz * 2
        m.title.translation = [m.rootPaddingHorz, m.rootPaddingVert]
        m.contentRoot.height = m.root.height - m.title.height - m.rootPaddingVert * 2
        m.contentRoot.width = m.title.width
        m.contentRoot.translation = [m.rootPaddingHorz, m.rootPaddingVert + m.title.height]
        m.contentRoot.clippingRect = [0, 0, m.contentRoot.width, m.contentRoot.height]

        layoutCollection()
    end if
end sub

sub layoutCollection()
    if m.top.content.getChildCount() = 0 then return

    card = createObject("RoSGNode", "VideoCard")
    card.content = m.top.content.getChild(0)
    card.height = m.contentRoot.height
    m.singleCardWidth = card.getChild(0).width + m.cardSpace
    m.xOffsetMax = m.singleCardWidth * m.top.content.getChildCount() - m.contentRoot.width

    rootWidth = m.contentRoot.width
    currentCard = abs(fix(m.xOffset / m.singleCardWidth))
    currentCardCopy = currentCard
    currentRecycleIndex = 0
    while currentCard < m.top.content.getChildCount()
        x0 = currentCard * m.singleCardWidth
        x1 = x0 + m.singleCardWidth
        if x0 < m.xOffset + rootWidth and x1 > m.xOffset
            videoCard = getRecycleView(currentRecycleIndex, currentCard)
            videoCard.content = m.top.content.getChild(currentCard)
            videoCard.height = m.contentRoot.height
            videoCard.translation = [x0 - m.xOffset, 0]
            currentCard = currentCard + 1
            currentRecycleIndex = currentRecycleIndex + 1
        else
            exit while
        end if
    end while

    while currentRecycleIndex < m.contentRoot.getChildCount()
        m.contentRoot.removeChildIndex(m.contentRoot.getChildCount() - 1)
    end while
    updatedHighlight()

    'print "-----laying cards from " + str(currentCardCopy) " to " + str(currentCard -1)
end sub

function getRecycleView(recycleIndex as integer, cardIndex as integer) as object
    if recycleIndex >= m.contentRoot.getChildCount()
        card = createObject("RoSGNode", "VideoCard")
        m.contentRoot.appendChild(card)
    end if
    card = m.contentRoot.getChild(recycleIndex)
    card.id = str(cardIndex)
    return card
end function

function isCardAwayFromXOffset(index as integer) as boolean
    if index < 0 then return false
    offset = index * m.singleCardWidth
    if offset > m.xOffset then return true
    return false
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    'print "video deck key event " + key
    if m.top.width > 0 and m.top.height > 0 and m.top.content <> invalid
        if key = "left"
            if press
                if m.top.currentItem - 1 >= 0
                    m.top.currentItem = m.top.currentItem - 1
                end if
                if isCardAwayFromXOffset(m.top.currentItem)
                    animScroll(0)
                else
                    animScroll(-1 * m.singleCardWidth)
                end if
            end if
            return true
        else if key = "right"
            if press
                if m.top.currentItem + 1 < m.top.content.getChildCount()
                    m.top.currentItem = m.top.currentItem + 1
                end if
                animScroll(m.singleCardWidth)
            end if
            return true
        end if
    end if
    return false
end function

sub updatedHighlight()
    for i = 0 to m.contentRoot.getChildCount() - 1 step 1
        card = m.contentRoot.getChild(i)
        if m.top.currentItem = val(card.id, 10) and m.top.active
            card.highlight = true
        else
            card.highlight = false
        end if
    end for
    m.top.history = {xOffset: m.xOffset, currentItem: m.top.currentItem}
    'print "deck current card is " + str(m.top.currentItem)
end sub

sub animScroll(deltaX as integer)
    if deltaX = 0 or m.inAnimation
        updatedHighlight()
        return
    end if
    if m.xOffset + deltaX < 0
        deltaX = 0 - m.xOffset
    else if m.xOffset + deltaX >= m.xOffsetMax
        deltaX = m.xOffsetMax - m.xOffset
    end if
    if deltaX = 0
        updatedHighlight()
        return
    end if

    'print "current delta " + str(deltaX) + " from offset " + str(m.xOffset)
    m.inAnimation = true
    m.animationGroup = createObject("RoSGNode", "ParallelAnimation")
    for i = 0 to m.contentRoot.getChildCount() - 1 step 1
        card = m.contentRoot.getChild(i)
        originPos = card.translation
        newPos = [card.translation[0] - deltaX, card.translation[1]]

        anim = m.animationGroup.createChild("Animation")
        anim.duration = 0.2
        interpolator = anim.createChild("Vector2DFieldInterpolator")
        interpolator.fieldToInterp = card.id + ".translation"
        interpolator.key = [0.0, 1.0]
        interpolator.keyValue = [originPos, newPos]
    end for
    m.xOffset = m.xOffset + deltaX
    m.animationGroup.observeField("state", "onAnimationDone")
    m.animationGroup.control = "start"
end sub

sub onAnimationDone()
    if m.animationGroup.state = "stopped"
        m.animationGroup.unobserveField("state")
        layoutCollection()
        m.inAnimation = false
    end if
end sub

sub setActive()
    updatedHighlight()
end sub

sub loadInstance(params as Object)
    print "loadInstance xOffset " + str(params.xOffset) + ", " + str(params.currentItem)
    m.xOffset = params.xOffset
    m.top.currentItem = params.currentItem
    layoutCollection()
end sub
