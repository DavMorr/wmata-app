# WMATA Developer Portal 

## Step-by-Step WMATA API Sign Up & Key Registration

### Summary

The following are step-by-step instructions for setting up a free WMATA developer account and API key registration. 

### Step 1: Navigate to the WMATA Developer Portal

1. Open your web browser and go to: [https://developer.wmata.com/](https://developer.wmata.com/)
2. You'll see the main developer portal page with the tagline "Welcome Developers! Train arrivals, bus predictions, schedules, and more. It's here, and it's all for free. Go build();"

### Step 2: Create a Developer Account

1. Click the **"Sign up"** button on the homepage
2. You'll be directed to a registration form where you'll need to provide:
   - Email address
   - Password
   - Basic account information
3. Complete the registration form and submit it
4. Check your email for a verification link and click it to activate your account

### Step 3: Log In to Your Account

1. Return to [https://developer.wmata.com/](https://developer.wmata.com/)
2. Log in using your newly created credentials
3. You'll be taken to your developer dashboard

### Step 4: Subscribe to the Default Free Tier

1. Once logged in, subscribe to the free default tier
2. Navigate to your profile or subscription section
3. The free tier includes:
   - Rate limit of 10 calls/second and 50,000 calls per day
   - Access to all WMATA APIs at no cost
   - Sufficient for most casual developers

### Step 5: Obtain Your API Key

1. Navigate to the **Profile** page via the menu
1. Copy the primary or secondary key from your profile
2. Your API key will be a 32-character alphanumeric string
3. Store this key securely - you'll need it for all API requests

### Step 6: Test Your API Key (Optional)

1. Navigate to the **API Documentation** section on the developer portal (**APIs** menu item)
2. Use the interactive API console to test your key
3. The portal provides automatically generated API Documentation with code samples in multiple languages

## What You Get Access To

- Real-time train arrival predictions
- Bus predictions and schedules  
- Station information and rail line data
- Service alerts and elevator/escalator status
- GTFS (General Transit Feed Specification) data
- All APIs and data are free of charge

## API Usage Notes

- Include your API key in the header of each request
- No OAuth or additional authentication required
- The WMATA also provides a demonstration key, but this should never be used in production applications as it is rate limited and subject to change

## Support

- **Technical questions:** [api-support@wmata.com](mailto:api-support@wmata.com)
- **License agreement:** [https://developer.wmata.com/license](https://developer.wmata.com/license)

## Rate Limits

- **Free tier:** 10 calls/second and 50,000 calls per day
- **Default tier:** Sufficient for most casual developers

