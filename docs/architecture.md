# Architecture

## Trust Boundaries & Network Design

The system is split into two Docker networks created by Terraform:
- `public-net`: External-facing network. Only Nginx and `api-service` are on this network.
- `private-net`: Internal network. Postgres, Redis, `ai-agent-service`, `worker`, `ehr-mock`, and the observability stack reside here.

```mermaid
graph TD
    User([External User]) --> Nginx
    
    subgraph public-net [Public Network (External Traffic)]
        Nginx --> api-service
    end
    
    subgraph private-net [Private Network (No Host Exposure)]
        api-service --> Postgres[(Postgres)]
        api-service --> Redis[(Redis)]
        api-service --> ai-agent-service
        api-service --> ehr-mock
        
        worker --> Redis
        worker --> Postgres
        worker --> ehr-mock
        
        Prometheus --> api-service
        Prometheus --> ai-agent-service
        Prometheus --> worker
        Prometheus --> cadvisor
    end
```

### Why Compose + Terraform?
For this 3-4 day scope, building a full Kubernetes cluster locally (e.g., Minikube/Kind) introduces massive overhead for networking and persistent volume management. 
Docker Compose combined with Terraform provides the exact same architectural paradigms (IaC, declarative state, containerization, internal DNS, isolated networks) but natively on Windows/Docker Desktop with minimal friction.

### Layer Responsibilities
- **Terraform**: Owns the "physical" infrastructure (Networks and persistent Storage Volumes). It defines the boundaries and where data lives.
- **Docker Compose**: Owns the application lifecycle (Compute). It maps the stateless containers to the networks and volumes provisioned by Terraform.
