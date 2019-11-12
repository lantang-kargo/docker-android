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
    ANDROID_HOME=/android-sdk-linux

# -------------------------------------------------------
# Set the Docker root folder as root
WORKDIR /

# -------------------------------------------------------
# Update OS related stuff
RUN apt --quiet update --yes && \
    apt --quiet install --yes wget tar unzip lib32stdc++6 lib32z1

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
    
# -------------------------------------------------------
# Set the environment path again
ENV PATH ${PATH}:${ANDROID_HOME}/build-tools/${ANDROID_BUILD_TOOLS}/
