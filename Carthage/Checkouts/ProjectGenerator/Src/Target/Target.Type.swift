//
//  Target.Type.swift
//  MKHProjGen
//
//  Created by Maxim Khatskevich on 3/16/17.
//  Copyright © 2017 Maxim Khatskevich. All rights reserved.
//

extension Project.Target
{
    public
    enum InternalType: String
    {
        case
            app = ":application",
            framework = ":framework",
            dynamicLibrary = ":library.dynamic",
            staticLibrary = ":library.static",
            bundle = ":bundle",
            unitTest = ":bundle.unit-test",
            uiTest = ":bundle.ui-testing",
            appExtension = ":app-extension",
            tool = ":tool",
            watchApp = ":application.watchapp",
            watchApp2 = ":application.watchapp2",
            watchKitExtension = ":watchkit-extension",
            watchKit2Extension = ":watchkit2-extension",
            tvAppExtension = ":tv-app-extension",
            messagesApp = ":application.messages",
            appExtensionMessages = ":app-extension.messages",
            appExtensionMessagesStickers = ":app-extension.messages-sticker-pack",
            xpcService = ":xpc-service"
    }
}
