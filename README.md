# Scalable E-commerce Big Data Platform
## Background
BuildItAll is a European consulting firm specialized in helping small and mid-sized companies build scalable Data Platforms. After securing €20M in Series A funding, BuildItAll was approached by a Belgian e-commerce client who generates massive amounts of data daily and wanted to become more data-driven.

Our team was tasked with setting up a cost-optimal, scalable Big Data Processing platform based on Apache Spark on the cloud.
This product demonstrates the proposed architecture and solution for enabling large-scale data ingestion, processing, and analytics capabilities for the client.

## Team members
- Choice Ugwuede [Github](https://github.com/Choiceugwuede)
- Abasifreke Nkanang [Github](https://github.com/Data-Bishop)
- Adewunmi Olaniyi [Github](https://github.com/protechanalysis)
- David Mark [Github](https://github.com/markdave123-py)

## Overview
The platform is designed to efficiently handle big data workloads while staying true to BuildItAll's core value of building cost-effective cloud solutions.
It uses AWS, Apache Spark, and Terraform to process large datasets efficiently.
It is designed to be cost-effective, easy to maintain, and ready for client onboarding.

## ⚙️ Solution Components

| Component | Purpose |
|:----------|:--------|
| [CI/CD (GitHub Actions)](https://github.com/Data-Bishop/Team5-BuildItAll-Data-Platform/blob/main/docs/codebase_and_ci_cd.md) | Automates code deployment and infrastructure updates |
| [Infrastructure (Terraform](https://github.com/Data-Bishop/Team5-BuildItAll-Data-Platform/blob/main/docs/terraform_infrastructure.md) | Automates cloud setup (IAM, S3, networking) |
| [Orchestration (Apache Airflow)](https://github.com/Data-Bishop/Team5-BuildItAll-Data-Platform/blob/main/docs/airflow_documentation.md) | Manages data pipeline workflows |
| [Spark jobs (PySpark)](https://github.com/Data-Bishop/Team5-BuildItAll-Data-Platform/blob/main/docs/spark_jobs.md) | Simulates realistic e-commerce datasets and processing |

## ☁️ Architecture Overview
![workflow](/assests/workflow.svg)
Clear [architecture documentation](https://github.com/Data-Bishop/Team5-BuildItAll-Data-Platform/blob/main/docs/architecture.md) outlining the platform’s design.

For Architecture documentation[ Click here](https://github.com/Data-Bishop/Team5-BuildItAll-Data-Platform/blob/main/docs/architecture.md)

## 🛠️ Technologies Used
- Cloud: AWS (S3, IAM)
- Big Data Framework: Apache Spark
- Workflow Orchestration: Apache Airflow
- Infrastructure: Terraform
- Automation: GitHub Actions
- Programming Languages: Python, PySpark


## Deploymemt
For immediate use, refer to the [documentation](https://github.com/Data-Bishop/Team5-BuildItAll-Data-Platform/blob/main/docs/onboarding_guuide.md)

## Key Features
1. Scalable Big Data Processing
Built with Apache Spark for seamless handling of large datasets. The platform supports both batch and real-time processing to meet dynamic business needs.

2. Cost-Optimized Cloud Infrastructure
Utilizes AWS to ensure efficient use of resources, optimizing costs without compromising performance. Built with Terraform for reproducible and version-controlled infrastructure.

3. Modular and Maintainable Architecture
Designed for easy scalability and maintainability, making future updates or onboarding new team members a smooth process. The modular setup ensures flexibility in adapting to evolving business requirements.

4. Automated Data Pipelines
Apache Airflow is used for orchestrating complex workflows, ensuring seamless data movement from raw to processed datasets, with monitoring and error handling built-in.

5. Data Storage with AWS S3
Structured in raw and processed data zones on S3, ensuring efficient data storage and easy access for analytics or future processing.

6. CI/CD Automation
GitHub Actions for continuous integration and continuous deployment, enabling automated testing, builds, and deployment of code and infrastructure.

7. Production-Ready Setup
Designed with best practices to meet production-level requirements for performance, security, and maintainability, ensuring readiness for full deployment.

8. Client Onboarding Ready
Built to be easily understood and managed by the client with a focus on user-friendly maintenance and smooth adoption for future scaling.

## Best Practices
- Infrastructure as Code (IaC):
All cloud resources (S3 buckets, IAM roles, networking) are provisioned using Terraform, ensuring reproducibility, version control, and easy updates.
- Modular Code Structure:
The repository is neatly organized into modules: infrastructure, orchestration, data generation, and CI/CD, improving maintainability and collaboration.
- Environment Separation:
Clear separation between raw and processed data zones in AWS S3, following data lake design principles.
- Comprehensive [documentations](https://github.com/Data-Bishop/Team5-BuildItAll-Data-Platform/tree/main/docs) to support onboarding, repository cloning, and commercial deployment.


