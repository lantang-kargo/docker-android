FROM openjdk:8-jdk

# -------------------------------------------------------
# Set the environment variables
# Check here for ANDROID_CLI_TOOLS number
# https://developer.android.com/studio (scroll to bottom)
# Check here for ANDROID_BUILD_TOOLS number
# https://developer.android.com/studio/releases/build-tools
ENV ANDROID_COMPILE_SDK=29 \
    ANDROID_CLI_TOOLS=4333796 \
    ANDROID_BUILD_TOOLS=29.0.2 \
    ANDROID_HOME=/android-sdk-linux \
    GCLOUD_URL="https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-290.0.1-linux-x86_64.tar.gz"

# -------------------------------------------------------
# Set the Docker root folder as root
WORKDIR /

# -------------------------------------------------------
# Update OS related stuff
RUN apt --quiet update --yes && \
    apt --quiet install --yes wget tar unzip lib32stdc++6 lib32z1 jq

# -------------------------------------------------------
# Download and install the Android SDK
RUN wget -q https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_CLI_TOOLS}.zip -O android-sdk-tools.zip \
    ; unzip -q android-sdk-tools.zip -d ${ANDROID_HOME} \
    ; rm android-sdk-tools.zip

# -------------------------------------------------------
# Set the environment path
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools

# -------------------------------------------------------
# Accept the Android SDK licenses agreement
RUN yes | sdkmanager  --licenses

# -------------------------------------------------------
# Create the repositories config
RUN touch /root/.android/repositories.cfg

# -------------------------------------------------------
# Install platform and build tools
RUN sdkmanager "tools" "platform-tools" \
    ; yes | sdkmanager --update --channel=3 \
    ; yes | sdkmanager \
    "platforms;android-${ANDROID_COMPILE_SDK}" \
    "platforms;android-28" \
    "build-tools;${ANDROID_BUILD_TOOLS}" \
    "build-tools;28.0.3" \
    "build-tools;29.0.0"

RUN sdkmanager --install "ndk;21.0.6113669" --channel=3;\
    sdkmanager --install "cmake;10.24988404"

# -------------------------------------------------------
# Install AWS
RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "/tmp/awscli-bundle.zip" \
    ; unzip /tmp/awscli-bundle.zip -d /tmp/ \
    ; /tmp/awscli-bundle/install -b /bin/aws \
    ; export PATH=/bin:$PATH \
    ; mkdir /.aws \
    ; touch /.aws/credentials \ 
    ; touch /.aws/config \
    ; rm -rf /tmp/*

# -------------------------------------------------------
# Install yarn
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    ; apt -y install nodejs \
    ; npm -g install yarn

# -------------------------------------------------------
# Install gcloud (need to do init in pipeline)
RUN curl -L ${GCLOUD_URL} |tar xvz && \
    /google-cloud-sdk/install.sh -q

# -------------------------------------------------------
# Set the environment path again
ENV PATH ${PATH}:${ANDROID_HOME}/build-tools/${ANDROID_BUILD_TOOLS}/:/google-cloud-sdk/bin
