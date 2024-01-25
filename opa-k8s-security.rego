package main

deny[msg] {
    input.kind = "service"
    not input.spec.type = "NodePort"
    msg = "Service type should be NodePort"
}

deny[msg] {
    input.kind = "Deployment"
    not input.spec.template.spec.containers[0].securityContext.runAsNonRoot = true
    msg = "COntainers must not run as root - use runAsNonRoot within container security context"
}