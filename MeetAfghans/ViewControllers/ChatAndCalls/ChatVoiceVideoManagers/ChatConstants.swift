//
//  ChatConstants.swift
//  ChatQuickstart
//
//  Created by Jeffrey Linwood on 3/28/20.
//  Copyright © 2020 Twilio, Inc. All rights reserved.
//

import Foundation

// Important - update this URL with your Twilio Function URL
// Important - this function must be protected in production
// and actually check if user could be granted access to your chat service.

// For the below compile error
// You will need to uncomment the string constant assignment
// And replace YOUR_TWILIO_FUNCTION_DOMAIN_HERE with your subdomain
var TOKEN_URL = CommonUrl.access_token_chat
	
