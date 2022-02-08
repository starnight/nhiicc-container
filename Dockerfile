FROM docker.io/library/debian:stable-slim

RUN apt update -y \
 && apt --no-install-recommends install ca-certificates libccid pcscd curl -y \
 && cd /tmp \
 && curl -L -O https://cloudicweb.nhi.gov.tw/cloudic/system/SMC/mLNHIICC_Setup.20210824.02.U64.gz \
 && tar xf mLNHIICC_Setup.20210824.02.U64.gz \
 && install -d /usr/local/share/NHIICC \
 && install mLNHIICC_Setup/x64/mLNHIICC /usr/local/share/NHIICC/mLNHIICC \
 && cp -dr --no-preserve=ownership mLNHIICC_Setup/web /usr/local/share/NHIICC/ \
 && install -d /usr/local/share/NHIICC/cert \
 && install mLNHIICC_Setup/cert/NHI* /usr/local/share/NHIICC/cert/ \
 && echo "#!/bin/sh\n\npcscd &\n/usr/local/share/NHIICC/mLNHIICC" > /usr/local/share/NHIICC/start.sh \
 && apt remove --purge -y curl \
 && apt autoremove -y \
 && apt clean -y \
 && cd /tmp && rm -rf /tmp/*

ENTRYPOINT ["sh", "/usr/local/share/NHIICC/start.sh"]
