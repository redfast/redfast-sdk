' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********  

sub init()
    m.sceneStack = m.top.findNode("sceneStack")
    scene = createObject("RoSGNode", "TemplateMain")
    scene.state = "initialize"
    scene.id = "0"
 
    m.sceneStack.appendChild(scene)
    initFocus = scene.findNode(scene.currFocusId)
    initFocus.setFocus(true)
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    result = false
    
    return result 
end function
