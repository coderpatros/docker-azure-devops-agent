FROM ubuntu:16.04

# To make it easier for build and release pipelines to run apt-get,
# configure apt to not require confirmation (assume the -y argument by default)
ENV DEBIAN_FRONTEND=noninteractive
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

RUN apt-get update \
&& apt-get install -y --no-install-recommends \
        apt-transport-https \
        wget \
        ca-certificates \
        curl \
        jq \
        git \
        iputils-ping \
        libcurl3 \
        libicu55 \
        libunwind8 \
        netcat

# Install some extra tools
RUN apt-get install -y --no-install-recommends \
        zip \
        unzip \
        python3 \
        python3-pip

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install Azure DevOps CLI
RUN az extension add --name azure-devops --yes

# Install PowerShell and the Az module
# Download the Microsoft repository GPG keys
# Register the Microsoft repository GPG keys
# Update the list of products
# Install PowerShell
# Install the Az module
RUN wget -q https://packages.microsoft.com/config/ubuntu/16.04/packages-microsoft-prod.deb \
&& dpkg -i packages-microsoft-prod.deb \
&& apt-get update \
&& apt-get install -y powershell \
&& pwsh -Command Install-Module -Name Az -AcceptLicense -AllowClobber -Scope AllUsers -Force

# Install .NET Core SDK
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
RUN apt-get install -y --no-install-recommends \
&& wget -q https://packages.microsoft.com/config/ubuntu/16.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
&& dpkg -i packages-microsoft-prod.deb \
&& rm packages-microsoft-prod.deb \
&& apt-get update \
&& apt-get install dotnet-sdk-2.2

# cleanup
RUN rm -rf /var/lib/apt/lists/*

WORKDIR /azp

COPY ./start.sh .
RUN chmod +x start.sh

CMD ["./start.sh"]
