FROM registry.access.redhat.com/ubi8/ubi

WORKDIR /app
ENV PATH="/app:${PATH}"

RUN yum install jq -y

COPY . ./
# RUN chown -R 1001:0 /app
# RUN chmod a+x /app/apicscript.sh /app/apic

# USER 1001
CMD apicscript.sh