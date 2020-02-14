' Copyright (C) 2020 Redfast Inc - All Rights Reserved
'
' It can not be copied and/or distributed without the express
' permission of Redfast Inc

sub init()
    m.contentRoot = m.top.findNode("contentRoot")

    m.yOffset = 0
    m.space = 20
    m.inAnimation = false
    m.currentItem = [0, 0]
end sub

sub setSize()
    if m.top.width > 0 and m.top.height > 0 and m.top.content <> invalid
        m.contentRoot.height = m.top.height
        m.contentRoot.width = m.top.width
        m.contentRoot.clippingRect = [0, 0, m.contentRoot.width, m.contentRoot.height]
        m.yOffsetMax = -1 * m.contentRoot.height
        m.history = []
        for i = 0 to m.top.content.getChildCount() - 1 step 1
            m.yOffsetMax = m.yOffsetMax + getDeckHeight(m.top.content.getChild(i))
            m.history.push({xOffset: 0, currentItem: 0})
        end for
        layoutCollection()
    end if
end sub

function getHeighByOrientation(rowContent as object) as integer
    if rowContent.contenttype = 1
        return 360
    end if
    return 300
end function

function getDeckHeight(rowContent as object) as integer
    return getHeighByOrientation(rowContent) + m.space
end function

function getFirstRow() as integer
    index = 0
    y0 = 0
    for i = 0 to m.top.content.getChildCount() - 1 step 1
        if y0 > m.yOffset then return index - 1
        index = index + 1
        y0 = y0 + getDeckHeight(m.top.content.getChild(i))
    end for
    return index
end function

sub layoutCollection()
    getRowPosition = function(rowIndex) 
        y0 = 0
        for i = 0 to rowIndex - 1 step 1
            y0 = y0 + getDeckHeight(m.top.content.getChild(i))
        end for
        return {
            top: y0,
            bottom: y0 + getDeckHeight(m.top.content.getChild(rowIndex))
        }
    end function

    rootHeight = m.contentRoot.height
    currentDeck = getFirstRow()
    currentDeckCopy = currentDeck
    currentRecycleIndex = 0
    while currentDeck < m.top.content.getChildCount()
        topBottom = getRowPosition(currentDeck)
        if topBottom.top < m.yOffset + rootHeight and topBottom.bottom > m.yOffset
            videoDeck = getRecycleView(currentRecycleIndex, currentDeck)
            videoDeck.content = m.top.content.getChild(currentDeck)
            videoDeck.callFunc("loadInstance", m.history[val(videoDeck.id, 10)])
            videoDeck.width = m.contentRoot.width
            videoDeck.height = getHeighByOrientation(m.top.content.getChild(currentDeck))
            videoDeck.translation = [0, topBottom.top - m.yOffset]
            currentDeck = currentDeck + 1
            currentRecycleIndex = currentRecycleIndex + 1
        else
            exit while
        end if
    end while

    while currentRecycleIndex < m.contentRoot.getChildCount()
        m.contentRoot.removeChildIndex(m.contentRoot.getChildCount() - 1)
    end while
    updatedHighlight()

    'print "#####laying shelf from " + str(currentDeckCopy) " to " + str(currentDeck -1)
end sub

sub getRecycleView(recycleIndex as integer, deckIndex as integer) as object
    if recycleIndex >= m.contentRoot.getChildCount()
        deck = createObject("RoSGNode", "VideoDeck")
        m.contentRoot.appendChild(deck)
    end if
    deck = m.contentRoot.getChild(recycleIndex)
    if deck.id <> invalid and deck.id <> ""
        m.history[val(deck.id, 10)] = deck.history
    end if
    deck.id = str(deckIndex)
    return deck
end sub

function isRowAwayFromYOffset(index as integer) as boolean
    if index < 0 then return false
    offset = 0
    for i = 0 to index - 1 step 1
        offset = offset + getDeckHeight(m.top.content.getChild(i))
    end for
    if offset > m.yOffset then return true
    return false
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    'print "video shelf key event " + key
    if m.top.width > 0 and m.top.height > 0 and m.top.content <> invalid
        if key = "up"
            if press
                if m.currentItem[0] - 1 >= 0
                    m.currentItem[0] = m.currentItem[0] - 1
                else
                    return false
                end if
                if isRowAwayFromYOffset(m.currentItem[0])
                    animScroll(0)
                else
                    currDeckHeight = getDeckHeight(m.top.content.getChild(m.currentItem[0]))
                    animScroll(-1 * currDeckHeight)
                end if
            end if
            return true
        else if key = "down"
            if press
                if m.currentItem[0] + 1 < m.top.content.getChildCount()
                    m.currentItem[0] = m.currentItem[0] + 1
                end if
                currDeckHeight = getDeckHeight(m.top.content.getChild(m.currentItem[0]))
                animScroll(currDeckHeight)
            end if
            return true
        end if
    end if
    return false
end function

sub updatedHighlight()
    for i = 0 to m.contentRoot.getChildCount() - 1 step 1
        deck = m.contentRoot.getChild(i)
        if m.currentItem[0] = val(deck.id, 10)
            if deck.currentItem < 0
               deck.currentItem = 0
            end if
            m.currentItem[1] = deck.currentItem
            deck.active = true
            deck.setFocus(true)
        else
            deck.active = false
        end if
    end for
    print "shelf current deck is " + str(m.currentItem[0]) + ", cell is " + str(m.currentItem[1])
end sub

function refreshFocus(params as Object)
    updatedHighlight()
end function

sub animScroll(deltaY as integer)
    if deltaY = 0 or m.inAnimation
        updatedHighlight()
        return
    end if
    if m.yOffset + deltaY < 0
        deltaY = 0 - m.yOffset
    else if m.yOffset + deltaY >= m.yOffsetMax
        deltaY = m.yOffsetMax - m.yOffset
    end if
    if deltaY = 0
        updatedHighlight()
        return
    end if

    'print "current delta " + str(deltaY) + " from offset " + str(m.yOffset)
    m.inAnimation = true
    m.animationGroup = createObject("RoSGNode", "ParallelAnimation")
    for i = 0 to m.contentRoot.getChildCount() - 1 step 1
        deck = m.contentRoot.getChild(i)
        originPos = deck.translation
        newPos = [deck.translation[0], deck.translation[1] - deltaY]

        anim = m.animationGroup.createChild("Animation")
        anim.duration = 0.2
        interpolator = anim.createChild("Vector2DFieldInterpolator")
        interpolator.fieldToInterp = deck.id + ".translation"
        interpolator.key = [0.0, 1.0]
        interpolator.keyValue = [originPos, newPos]
    end for
    m.yOffset = m.yOffset + deltaY
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
