# APIC_tekton_task
Container for running APIC tasks within Tekton

    docker build -t registry/namespace/apic-tekton:latest .

    docker push registry/namespace/apic-tekton:latest

    docker run --env-file apic-vars.env registry/namespace/apic-tekton:latest 


Whenever you are changing apicscript.sh make sure to save it as UNIX format (LF).