' Copyright (C) 2020 Redfast Inc - All Rights Reserved
'
' It can not be copied and/or distributed without the express
' permission of Redfast Inc
 
 sub init()
    m.shelf = m.top.findNode("shelf")
    m.unsubscribe = m.top.findNode("unsubscribe")
    m.task = createObject("RoSGNode", "MovieApi")
    m.task.observeField("state", "onThreadComplete")
    m.task.callFunc("getMovies", {})
    m.unsubscribe.ObserveField("buttonSelected", "onUnsubscribe")
    m.top.currFocusId = "shelf"
    m.retentMgr = m.top.findNode("retentMgr")
    m.retentMgr.appId = "74f72649-0327-4911-bd21-a4cd533cec1c"
    m.retentMgr.userId = "123"
    m.retentMgr.isProd= true
    m.retentMgr.callFunc("initPromotion", {})
    m.retentMgr.observeField("result", "onModalDismissed")
    m.viewRoot = m.top.findNode("root")
end sub

sub onThreadComplete()
    if m.task.state = "stop"
        m.task.unobserveField("state")
        if m.task.content <> invalid
            m.shelf.currentItem = [0, 0]
            m.shelf.content = m.task.content
            m.shelf.height = 870
            m.shelf.width = 1840
            
            m.retentMgr.callFunc("onScreenChanged", {root: m.viewRoot, screenName: "ViewController" })
        end if
    end if
end sub

sub onUnsubscribe()
   m.retentMgr.callFunc("onButtonClicked", {root: m.viewRoot, id: "accessibility-123"}) 
end sub

sub onModalDismissed()
    print "modal result = " + m.retentMgr.result.toStr()
    if m.retentMgr.result = 0 'accepted
        dialog = createObject("roSGNode", "Dialog")
        dialog.title = "Thank you"
        dialog.optionsDialog = true
        dialog.message = "You have successfully accept the offer"
        m.top.dialog = dialog
    end if
    m.unsubscribe.setFocus(true)
end sub

function onKeyEvent(key as string, pressed as boolean) as boolean
    print "template main key event " + key
    if key = "up" and pressed
        m.unsubscribe.setFocus(true)
    else if key = "down" and pressed
        m.shelf.callFunc("refreshFocus", {})
    end if
    return true
end function