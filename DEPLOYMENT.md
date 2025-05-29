# Stan's List - AWS Amplify Deployment Guide

This guide provides step-by-step instructions for deploying the Stan's List Flutter web application to AWS Amplify and configuring the custom domain.

## Prerequisites

- [AWS Account](https://aws.amazon.com/)
- [AWS CLI](https://aws.amazon.com/cli/) installed and configured
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.10.0 or higher)
- Domain name (for this project: `stanleyluong.com`)

## Deployment Steps

### 1. Prepare Your Flutter Web App

✅ We've already taken care of:
- Fixed the Flutter web initialization in `index.html`
- Created proper PWA icons
- Added a loading indicator
- Configured `amplify.yml` for build settings

### 2. Test Locally Before Deploying

```bash
# Build your web app
flutter build web --release --dart-define=FLUTTER_WEB_USE_SKIA=true

# Test locally using the included script
./serve_local.sh
# Then visit http://localhost:8000 in your browser
```

### 3. Deploy to AWS Amplify Console

1. **Log in to the [AWS Management Console](https://console.aws.amazon.com/)**

2. **Navigate to AWS Amplify**:
   - Search for "Amplify" in the AWS console search bar
   - Click on "Amplify" from the results

3. **Create a new Amplify App**:
   - Click "New app" → "Host web app"
   - Choose your repository provider (GitHub, Bitbucket, GitLab, or AWS CodeCommit)
   - Authorize AWS Amplify to access your repository
   - Select the `stanslist` repository
   - Choose the `main` branch (or your preferred branch)

4. **Configure Build Settings**:
   - You don't need to modify anything as we already have the `amplify.yml` file
   - Your build settings should automatically be detected from the repository

5. **Review and Confirm**:
   - Review the configuration
   - Click "Save and deploy"

### 4. Configure Custom Domain

1. **In the Amplify Console**:
   - Select your app (Stan's List)
   - Click on "Domain management" in the left menu
   - Click "Add domain"

2. **Enter Your Domain**:
   - Enter `stanleyluong.com` as your root domain
   - Click "Configure domain"

3. **Configure Subdomains**:
   - For the root domain (`stanleyluong.com`), select the branch you want to deploy (typically `main`)
   - Add a subdomain `stanslist.stanleyluong.com` and select the same branch
   - Click "Save"

4. **Update DNS Records**:
   - AWS will provide you with DNS records to add to your domain provider
   - Go to your domain provider's website (where you registered `stanleyluong.com`)
   - Add the CNAME records provided by AWS Amplify
   - For the root domain, you might need to add an ANAME/ALIAS record (depending on your provider)

5. **Wait for DNS Propagation**:
   - DNS changes can take up to 48 hours to propagate
   - Amplify will automatically issue an SSL certificate for your domain

### 5. Verify Deployment

Once DNS propagation is complete:
- Visit `https://stanslist.stanleyluong.com` to verify your app is working
- Check that PWA features are working correctly
- Test the responsive design on different devices

## Troubleshooting

### Common Issues and Solutions

1. **Build Failures**:
   - Check the build logs in the Amplify Console
   - Ensure all dependencies are properly specified in `pubspec.yaml`

2. **Custom Domain Not Working**:
   - Verify DNS records are correctly set up at your domain provider
   - Check if the SSL certificate has been issued (may take up to 24 hours)

3. **App Not Loading Properly**:
   - Check browser console for errors
   - Ensure all assets are correctly referenced in the app

4. **PWA Features Not Working**:
   - Verify that `manifest.json` is correctly configured
   - Check that all required icon sizes are available

## Maintenance

### Updating Your Deployed App

1. **Push changes to your repository**:
   ```bash
   git add .
   git commit -m "Update app with new features"
   git push origin main
   ```

2. **Automatic Deployment**:
   - AWS Amplify will automatically detect the changes and start a new build
   - You can monitor the build progress in the Amplify Console

3. **Manual Deployment**:
   - In the Amplify Console, select your app
   - Click on "Hosting environments"
   - Find your branch and click "Redeploy this version"

### Monitoring

- Use AWS Amplify's built-in analytics to monitor app usage
- Set up alerts for build failures and deployment issues

## Resources

- [AWS Amplify Documentation](https://docs.aws.amazon.com/amplify/)
- [Flutter Web Documentation](https://flutter.dev/docs/deployment/web)
- [Custom Domains in AWS Amplify](https://docs.aws.amazon.com/amplify/latest/userguide/custom-domains.html)
