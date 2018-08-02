# First, make sure that you have no uncommitted changes in the current repository (fastlane doesn't like that).
#
# Build:  docker build . -t coredump/mattermost-mobile-build:latest
# Run:    docker run --rm -t -i \
#             -v /home/danilo/Projects/coredump/googleplay/:/config \
#             -v /home/danilo/Documents/Coredump/Sync/Chat/:/out \
#             coredump/mattermost-mobile-build:latest /bin/bash build.sh

FROM circleci/android:api-28-node

# Generate locales
RUN sudo bash -c "echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen"
RUN sudo locale-gen

# Install dependencies
RUN gem install fastlane nokogiri aws-sdk-s3

# Code directory
WORKDIR /code

# Add code
ADD . /code/
USER root
RUN chown -R 3434:3434 /code/
USER 3434
