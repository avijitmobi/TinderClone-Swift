//
//  TwilloChatManager.swift
//  TwilloChatManager
//

import UIKit
import TwilioChatClient

protocol TwilloChatManagerDelegate: AnyObject {
    func reloadMessages()
    func receivedNewMessage()
}

class TwilloChatManager: NSObject, TwilioChatClientDelegate {

    // the unique name of the channel you create
    var uniqueChannelName = "chatRoom"
    private let friendlyChannelName = "MeetAftghansChat"

    // For the quickstart, this will be the view controller
    weak var delegate: TwilloChatManagerDelegate?

    // MARK: Chat variables
    private var client: TwilioChatClient?
    private var channel: TCHChannel?
    public var messages: [TCHMessage] = []
    private var identity: String?
    

    func chatClient(_ client: TwilioChatClient, synchronizationStatusUpdated status: TCHClientSynchronizationStatus) {
        guard status == .completed else {
            return
        }
        checkChannelCreation { (_, channel) in
            if let channel = channel {
                self.joinChannel(channel)
            } else {
                self.createChannel { (success, channel) in
                    if success, let channel = channel {
                        self.joinChannel(channel)
                    }
                }
            }
        }
    }

    // Called whenever a channel we've joined receives a new message
    func chatClient(_ client: TwilioChatClient, channel: TCHChannel,
                    messageAdded message: TCHMessage) {
        messages.append(message)

        DispatchQueue.main.async {
            if let delegate = self.delegate {
                delegate.reloadMessages()
                if self.messages.count > 0 {
                    delegate.receivedNewMessage()
                }
            }
        }
    }
    
    func chatClientTokenWillExpire(_ client: TwilioChatClient) {
        print("Chat Client Token will expire.")
        // the chat token is about to expire, so refresh it
        refreshAccessToken()
    }
    
    private func refreshAccessToken() {
        guard let identity = identity else {
            return
        }
        let urlString = "\(TOKEN_URL)?identity=\(identity)"

        TokenUtils.retrieveToken(url: urlString) { (token, _, error) in
            guard let token = token else {
               print("Error retrieving token: \(error.debugDescription)")
               return
           }
            self.client?.updateToken(token, completion: { (result) in
                if (result.isSuccessful()) {
                    print("Access token refreshed")
                } else {
                    print("Unable to refresh access token")
                }
            })
        }
    }
    
    func sendFile(with data: Data,param : [String : String],on vc: UIViewController,completion: @escaping (TCHResult, TCHMessage?) -> Void) {
        // Prepare the upload stream and parameters
        let messageOptions = TCHMessageOptions()
        vc.view.makeToastActivity(vc.view.center)
        let inputStream = InputStream(data: data)
        messageOptions.withMediaStream(inputStream,contentType: "image/jpeg",defaultFilename: "image.jpg",onStarted: {
            // Called when upload of media begins.
            print("Media upload started")
        },onProgress: { (bytes) in
            // Called as upload progresses, with the current byte count.
            print("Media upload progress: \(bytes)")
        }) { (mediaSid) in
            // Called when upload is completed, with the new mediaSid if successful.
            // Full failure details will be provided through sendMessage's completion.
            print("Media upload completed")
            vc.view.hideToastActivity()
        }
        // Trigger the sending of the message.
        self.channel?.messages?.sendMessage(with: messageOptions, completion: { (result, message) in
            vc.view.hideToastActivity()
            completion(result,message)
            APIReqeustManager.sharedInstance.uploadWithAlamofire(multipart: { (multiPartData) in
                multiPartData.append(data, withName: "image", fileName: "image", mimeType: "image/jpeg")
                param.forEach { (key,value) in
                    multiPartData.append(value.data(using: .utf8) ?? Data(), withName: key)
                }
            }, url: CommonUrl.send_chat, method: .post, loadingButton: nil, loaderNeed: false, needViewHideShowAfterLoading: nil, vc: vc, isTokenNeeded: true, progressValue: { (progressValue) in
            }, isErrorAlertNeeded: true,errorBlock : nil, actionErrorOrSuccess: { (isSuccess, message) in
                
            }, fromLoginPageCallBack: nil) { (_, _) in
            }
        })
    }

    func sendMessage(_ messageText: String,param : [String : String],from : UIViewController,completion: @escaping (TCHResult, TCHMessage?) -> Void) {
        if let messages = self.channel?.messages {
            
            let messageOptions = TCHMessageOptions().withBody(messageText)
            messages.sendMessage(with: messageOptions, completion: { (result, message) in
                completion(result, message)
                APIReqeustManager.sharedInstance.uploadWithAlamofire(multipart: { (multiPartData) in
                    param.forEach { (key,value) in
                        multiPartData.append(value.data(using: .utf8) ?? Data(), withName: key)
                    }
                }, url: CommonUrl.send_chat, method: .post, loadingButton: nil, loaderNeed: false, needViewHideShowAfterLoading: nil, vc: from, isTokenNeeded: true, progressValue: { (progressValue) in
                }, isErrorAlertNeeded: true,errorBlock : nil, actionErrorOrSuccess: { (isSuccess, message) in
                    
                }, fromLoginPageCallBack: nil) { (_, _) in
                }
            })
        }
    }

    func login(_ identity: String, completion: @escaping (Bool) -> Void) {
        // Fetch Access Token from the server and initialize Chat Client - this assumes you are
        // calling a Twilio function, as described in the Quickstart docs
        let urlString = "\(TOKEN_URL)?identity=\(identity)"
        self.identity = identity

        TokenUtils.retrieveToken(url: urlString) { (token, _, error) in
            guard let token = token else {
                print("Error retrieving token: \(error.debugDescription)")
                completion(false)
                return
            }
            // Set up Twilio Chat client
            TwilioChatClient.chatClient(withToken: token, properties: nil,
                                        delegate: self) { (result, chatClient) in
                self.client = chatClient
                completion(result.isSuccessful())
            }
        }
    }

    func shutdown() {
        if let client = client {
            client.delegate = nil
            client.shutdown()
            self.client = nil
        }
    }

    private func createChannel(_ completion: @escaping (Bool, TCHChannel?) -> Void) {
        guard let client = client, let channelsList = client.channelsList() else {
            return
        }
        // Create the channel if it hasn't been created yet
        let options: [String: Any] = [
            TCHChannelOptionUniqueName: uniqueChannelName,
            TCHChannelOptionFriendlyName: friendlyChannelName,
            TCHChannelOptionType: TCHChannelType.public.rawValue
        ]
        channelsList.createChannel(options: options, completion: { channelResult, channel in
            if channelResult.isSuccessful() {
                print("Channel created.")
            } else {
                print("Channel NOT created.")
            }
            completion(channelResult.isSuccessful(), channel)
        })
    }

    private func checkChannelCreation(_ completion: @escaping(TCHResult?, TCHChannel?) -> Void) {
        guard let client = client, let channelsList = client.channelsList() else {
            return
        }
        channelsList.channel(withSidOrUniqueName: uniqueChannelName, completion: { (result, channel) in
            completion(result, channel)
        })
    }

    private func joinChannel(_ channel: TCHChannel) {
        self.channel = channel
        if channel.status == .joined {
            print("Current user already exists in channel")
        } else {
            channel.join(completion: { result in
                print("Result of channel join: \(result.resultText ?? "No Result")")
            })
        }
    }
}
