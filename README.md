# Code Challenge: Cloud Platform Engineering

**Objective:**

Design and implement a production-ready AWS infrastructure for one of three applications: Twenty CRM, LiteLLM Proxy, or N8N. This challenge assesses your ability to architect, deploy, and manage cloud infrastructure with modern DevOps practices and infrastructure as code.

## Application Choices:

#### Option 2: LiteLLM Proxy
- **Purpose**: Unified API gateway for multiple LLM providers
- **Technology**: Python FastAPI, PostgreSQL, Redis
- **Features**: Model routing, cost tracking, rate limiting
- **Complexity**: Medium (3 services: API, database, cache)

#### Cloud Infrastructure Architecture:
```mermaid
graph TB
    subgraph "Internet"
        Users[End Users]
    end
    
    subgraph "AWS Cloud"
        subgraph "Edge Layer"
            CloudFront[CloudFront CDN]
            Route53[Route 53 DNS]
            WAF[AWS WAF]
        end
        
        subgraph "Application Layer"
            ALB[Application Load Balancer]
            ECS[ECS Fargate Cluster]
            App1[Application Service]
            App2[Worker Service]
        end
        
        subgraph "Data Layer"
            RDS[(RDS PostgreSQL)]
            ElastiCache[(ElastiCache Redis)]
            S3[S3 Storage]
        end
        
        subgraph "Security & Monitoring"
            IAM[IAM Roles]
            KMS[KMS Encryption]
            CloudWatch[CloudWatch]
            Secrets[Secrets Manager]
        end
        
        subgraph "CI/CD Pipeline"
            CodeCommit[CodeCommit]
            CodeBuild[CodeBuild]
            CodeDeploy[CodeDeploy]
        end
    end
    
    Users --> CloudFront
    CloudFront --> WAF
    WAF --> ALB
    ALB --> ECS
    ECS --> App1
    ECS --> App2
    
    App1 --> RDS
    App1 --> ElastiCache
    App1 --> S3
    
    App2 --> RDS
    App2 --> ElastiCache
    
    IAM --> ECS
    KMS --> RDS
    KMS --> S3
    CloudWatch --> ECS
    Secrets --> ECS
    
    CodeCommit --> CodeBuild
    CodeBuild --> CodeDeploy
    CodeDeploy --> ECS
```

## Requirements:

### Phase 1: Infrastructure Design & Core Deployment (2-3 days)

#### Infrastructure as Code (IaC):
- **Terraform or CloudFormation**: Basic infrastructure provisioning
- **Modular Design**: Organized, reusable components
- **Environment Management**: Single production environment
- **State Management**: Basic Terraform state management or CloudFormation stacks
- **Variable Management**: Environment-specific configurations

#### Core Infrastructure Components:
- **VPC Design**: Multi-AZ VPC with public and private subnets
- **Networking**: Security groups, route tables, internet/NAT gateways
- **Load Balancing**: Application Load Balancer with SSL/TLS termination
- **Auto Scaling**: Basic horizontal scaling policies
- **Database**: RDS PostgreSQL with basic configuration
- **Caching**: ElastiCache Redis (for LiteLLM and N8N)
- **Storage**: S3 buckets for file storage
- **Basic Monitoring**: CloudWatch for essential metrics

#### Application-Specific Infrastructure:

##### For LiteLLM Proxy:
- **ECS Fargate**: Container orchestration for LiteLLM proxy
- **RDS PostgreSQL**: Database for user management and request logging
- **ElastiCache Redis**: Caching layer for responses and sessions

### Phase 2: DevOps & Security Implementation (1-2 days)

#### Basic CI/CD Pipeline:
- **GitHub Actions or AWS CodePipeline**: Simple automated deployment pipeline
- **Container Registry**: ECR for Docker image management
- **Basic Security**: Container vulnerability scanning
- **Testing**: Basic infrastructure testing

#### Configuration Management:
- **Secrets Management**: AWS Secrets Manager for sensitive data
- **Parameter Store**: Basic application configuration management
- **Environment Variables**: Secure environment variable handling

#### Monitoring & Observability:
- **Logging**: Basic CloudWatch Logs setup
- **Metrics**: Essential CloudWatch metrics and dashboards
- **Alerting**: Basic automated alerting for critical issues
- **Health Checks**: Application and infrastructure health monitoring

#### Security Implementation:
- **IAM**: Basic least privilege access with role-based permissions
- **Encryption**: Data encryption at rest and in transit
- **Network Security**: VPC security and basic WAF rules
- **Backup**: Basic automated backup procedures

## Technical Requirements:

### Infrastructure Architecture:
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Internet      │    │   ALB + WAF     │    │   ECS Fargate   │
│                 │───▶│                 │───▶│   (Containers)  │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │                       │
                                ▼                       ▼
                       ┌─────────────────┐    ┌─────────────────┐
                       │   S3 Storage    │    │   RDS + Redis   │
                       │   + Backups     │    │   (Database)    │
                       └─────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │   CloudWatch    │
                       │   + Monitoring  │
                       └─────────────────┘
```

### Technology Stack:
- **IaC**: Terraform or CloudFormation
- **Container Orchestration**: ECS Fargate
- **Database**: RDS PostgreSQL
- **Caching**: ElastiCache Redis (for LiteLLM and N8N)
- **Storage**: S3
- **Load Balancing**: ALB with SSL termination
- **Monitoring**: CloudWatch
- **CI/CD**: GitHub Actions or AWS CodePipeline

### Application-Specific Configurations:

#### Twenty CRM Configuration:
```yaml
# docker-compose.yml
version: '3.8'
services:
  twenty-server:
    image: twentyhq/twenty-server:latest
    environment:
      - APP_SECRET=${APP_SECRET}
      - SERVER_URL=${SERVER_URL}
      - PGPASSWORD_SUPERUSER=${PGPASSWORD_SUPERUSER}
    volumes:
      - twenty-data:/app/storage
    depends_on:
      - postgres

  twenty-worker:
    image: twentyhq/twenty-worker:latest
    environment:
      - APP_SECRET=${APP_SECRET}
      - PGPASSWORD_SUPERUSER=${PGPASSWORD_SUPERUSER}
    depends_on:
      - postgres

  postgres:
    image: postgres:15
    environment:
      - POSTGRES_PASSWORD=${PGPASSWORD_SUPERUSER}
    volumes:
      - postgres-data:/var/lib/postgresql/data

volumes:
  twenty-data:
  postgres-data:
```

#### LiteLLM Configuration:
```yaml
# litellm-config.yaml
model_list:
  - model_name: gpt-4o
    litellm_params:
      model: azure/gpt-4o
      api_base: os.environ/AZURE_API_BASE
      api_key: os.environ/AZURE_API_KEY
      api_version: "2025-01-01-preview"

general_settings:
  master_key: os.environ/LITELLM_MASTER_KEY
  database_url: os.environ/DATABASE_URL
  redis_url: os.environ/REDIS_URL
  block_robots: true

litellm_settings:
  drop_params: true
```

## Deliverables:

### Phase 1 Deliverables:
- **Infrastructure as Code**: Complete Terraform or CloudFormation templates
- **Architecture Diagram**: Infrastructure design overview
- **Application Deployment**: Working application deployment
- **Basic Documentation**: Setup and configuration guide

### Phase 2 Deliverables:
- **CI/CD Pipeline**: Basic automated deployment pipeline
- **Security Implementation**: Essential security controls
- **Monitoring Setup**: Basic dashboards and alerting
- **Final Documentation**: Complete deployment and operation guide

## Evaluation Criteria:

### Infrastructure Design (40%):
- **Architecture Quality**: Scalable and secure design
- **IaC Quality**: Clean, modular, and reusable code
- **Best Practices**: AWS well-architected framework compliance
- **Documentation**: Clear and comprehensive documentation

### DevOps Implementation (35%):
- **CI/CD Pipeline**: Automated and reliable deployment process
- **Configuration Management**: Secure configuration handling
- **Monitoring**: Essential observability and alerting
- **Testing**: Basic infrastructure and application testing

### Security & Operations (25%):
- **Security Controls**: Essential security implementation
- **Backup & Recovery**: Basic disaster recovery capabilities
- **Cost Management**: Resource optimization and cost control
- **Operational Excellence**: Production-ready deployment

## Timeline:

This challenge is designed to be completed in **3-5 business days**:

#### **Days 1-2: Infrastructure Design & Core Deployment**
- Choose application and design architecture
- Create infrastructure as code templates
- Deploy core infrastructure components
- Configure application-specific services

#### **Days 3-4: DevOps & Security Implementation**
- Implement CI/CD pipeline
- Configure security controls
- Set up monitoring and logging
- Deploy and test application

#### **Day 5: Testing & Documentation**
- Final testing and validation
- Performance optimization
- Complete documentation
- Final review and submission

## Priority Focus Areas:

#### **Must Complete (High Priority):**
- Core infrastructure deployment
- Application deployment and configuration
- Basic CI/CD pipeline
- Essential security controls
- Basic monitoring and logging setup

#### **Should Complete (Medium Priority):**
- Advanced security features
- Performance optimization
- Comprehensive monitoring
- Cost optimization
- Basic testing implementation

#### **Nice to Have (Low Priority):**
- Advanced CI/CD features
- Disaster recovery automation
- Advanced monitoring and alerting
- Performance benchmarking
- Detailed cost analysis

## Questions?

Any questions you may have, please contact us by e-mail.

Good luck! 🚀
