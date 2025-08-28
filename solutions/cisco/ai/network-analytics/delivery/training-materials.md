# Training Materials - Cisco AI Network Analytics

## Overview

This document provides comprehensive training materials for Cisco AI Network Analytics solutions. It includes curriculum for different user roles, hands-on exercises, certification paths, and ongoing education resources.

## Training Framework

### Learning Objectives
- Understand AI-driven network analytics concepts and benefits
- Deploy and configure Cisco AI network analytics platforms
- Operate and maintain AI analytics solutions effectively
- Troubleshoot common issues and optimize performance
- Leverage AI insights for proactive network management

### Target Audiences

| Role | Training Level | Duration | Prerequisites |
|------|---------------|----------|---------------|
| **Network Administrators** | Intermediate | 16 hours | Basic networking, CCNA |
| **Network Engineers** | Advanced | 24 hours | CCNP, 3+ years experience |
| **AI/ML Engineers** | Expert | 32 hours | ML background, Python |
| **Operations Teams** | Basic-Intermediate | 12 hours | Basic IT operations |
| **Management** | Executive | 4 hours | Business leadership |

## Training Curriculum

### Module 1: AI Network Analytics Fundamentals (4 hours)

#### Learning Objectives
- Understand AI/ML concepts in network management
- Identify business benefits and use cases
- Overview of Cisco AI analytics portfolio

#### Content Outline

**1.1 Introduction to AI in Networking (1 hour)**
- Traditional vs. AI-powered network management
- Machine learning fundamentals for networking
- Types of AI analytics: Predictive, prescriptive, descriptive
- Industry trends and market drivers

**1.2 Cisco AI Analytics Portfolio (1 hour)**
- DNA Center AI capabilities
- Catalyst Center intelligence features
- ThousandEyes AI-powered insights
- Crosswork automation and optimization

**1.3 Business Benefits and ROI (1 hour)**
- Operational cost reduction strategies
- Performance improvement metrics
- Security enhancement through AI
- Real-world customer success stories

**1.4 Use Cases and Applications (1 hour)**
- Network performance optimization
- Predictive maintenance scenarios
- Security threat detection
- Capacity planning and management

#### Hands-On Lab 1.1: AI Analytics Dashboard Exploration
```yaml
lab_exercise:
  title: "Exploring AI Analytics Dashboard"
  duration: 45_minutes
  objectives:
    - Navigate DNA Center AI analytics interface
    - Identify key performance indicators
    - Interpret AI-generated insights
  
  tasks:
    - task: "Access AI Analytics Dashboard"
      instructions: |
        1. Log into DNA Center lab environment
        2. Navigate to Assurance > AI Analytics
        3. Explore the main dashboard components
      expected_outcome: "Understand dashboard layout and key metrics"
    
    - task: "Review AI Insights"
      instructions: |
        1. Click on "Network Insights" section
        2. Examine anomaly detection alerts
        3. Review predictive analytics trends
      expected_outcome: "Interpret AI-generated network insights"
    
    - task: "Analyze Historical Trends"
      instructions: |
        1. Select different time ranges (1d, 7d, 30d)
        2. Compare performance trends
        3. Identify patterns and anomalies
      expected_outcome: "Understand historical trend analysis"
```

#### Assessment 1: Fundamentals Quiz
- 20 multiple choice questions
- Passing score: 80%
- Topics: AI concepts, Cisco portfolio, business benefits

### Module 2: DNA Center AI Configuration (6 hours)

#### Learning Objectives
- Install and configure AI analytics features
- Set up data collection and baseline monitoring
- Configure assurance policies and alerts

#### Content Outline

**2.1 AI Analytics Setup (2 hours)**
- Prerequisites and licensing requirements
- Enabling AI analytics services
- Initial configuration and validation

**2.2 Data Collection Configuration (2 hours)**
- Configuring device monitoring
- Setting up data collection policies
- Baseline establishment and tuning

**2.3 Assurance Policies and Alerting (2 hours)**
- Creating AI-enhanced assurance policies
- Configuring intelligent alerting
- Setting up automated workflows

#### Hands-On Lab 2.1: DNA Center AI Configuration
```yaml
lab_exercise:
  title: "DNA Center AI Analytics Configuration"
  duration: 3_hours
  prerequisites:
    - DNA Center 2.3.7+ lab environment
    - Network devices discovered and managed
    - DNA Advantage licensing
  
  setup_tasks:
    - task: "Enable AI Analytics"
      api_call: |
        curl -X POST "https://dnac-lab.company.com/dna/intent/api/v1/ai-analytics/settings" \
          -H "X-Auth-Token: $LAB_TOKEN" \
          -d '{
            "aiAnalytics": {
              "enabled": true,
              "anomalyDetection": true,
              "predictiveAnalytics": true
            }
          }'
      validation: "Verify AI analytics status shows 'operational'"
    
    - task: "Configure Data Collection"
      configuration: |
        {
          "collection": {
            "interval": 300,
            "metrics": [
              "interface_utilization",
              "cpu_utilization",
              "memory_utilization",
              "error_rates"
            ]
          }
        }
      validation: "Confirm data collection is active for all devices"
    
    - task: "Create Assurance Policy"
      configuration: |
        {
          "policy": {
            "name": "Lab AI Health Policy", 
            "rules": [
              {
                "metric": "interface_utilization",
                "threshold": 80,
                "aiEnabled": true
              }
            ]
          }
        }
      validation: "Policy created and applied to network scope"
```

### Module 3: Advanced AI Model Configuration (8 hours)

#### Learning Objectives
- Configure and tune AI models for specific use cases
- Implement custom analytics rules
- Optimize model performance and accuracy

#### Content Outline

**3.1 AI Model Architecture (2 hours)**
- Understanding AI model types and algorithms
- Model training and validation processes
- Performance metrics and evaluation

**3.2 Anomaly Detection Configuration (3 hours)**
- Configuring anomaly detection models
- Tuning sensitivity and threshold parameters
- Handling false positives and negatives

**3.3 Capacity Prediction Setup (3 hours)**
- Time series forecasting configuration
- Historical data requirements and preparation
- Prediction accuracy optimization

#### Hands-On Lab 3.1: AI Model Training and Optimization
```python
# Lab Exercise: AI Model Training Script
"""
AI Model Training and Optimization Lab
Duration: 4 hours
"""

import requests
import json
import time
import numpy as np
from sklearn.metrics import accuracy_score, precision_score, recall_score

class AIModelTrainingLab:
    def __init__(self, dnac_url, token):
        self.dnac_url = dnac_url
        self.token = token
        self.headers = {"X-Auth-Token": token}
    
    def exercise_1_model_initialization(self):
        """Exercise 1: Initialize and configure AI models"""
        print("Exercise 1: AI Model Initialization")
        
        # Step 1: Initialize anomaly detection model
        anomaly_config = {
            "model": {
                "name": "lab_anomaly_detector",
                "algorithm": "isolation_forest",
                "parameters": {
                    "contamination": 0.1,
                    "n_estimators": 100
                }
            }
        }
        
        response = requests.post(
            f"{self.dnac_url}/dna/intent/api/v1/ai/models/anomaly-detection",
            headers=self.headers,
            json=anomaly_config
        )
        
        print(f"Model initialization status: {response.status_code}")
        
        # Step 2: Verify model status
        status_response = requests.get(
            f"{self.dnac_url}/dna/intent/api/v1/ai/models/status",
            headers=self.headers
        )
        
        models = status_response.json()
        print(f"Available models: {[m['name'] for m in models.get('models', [])]}")
        
        return response.status_code == 200
    
    def exercise_2_model_training(self):
        """Exercise 2: Train AI models with historical data"""
        print("\nExercise 2: Model Training")
        
        # Step 1: Prepare training data
        training_data = self.prepare_training_data()
        
        # Step 2: Start model training
        training_config = {
            "model_name": "lab_anomaly_detector",
            "training_data": training_data,
            "validation_split": 0.2
        }
        
        training_response = requests.post(
            f"{self.dnac_url}/dna/intent/api/v1/ai/models/train",
            headers=self.headers,
            json=training_config
        )
        
        training_job_id = training_response.json().get("job_id")
        print(f"Training job started: {training_job_id}")
        
        # Step 3: Monitor training progress
        while True:
            progress_response = requests.get(
                f"{self.dnac_url}/dna/intent/api/v1/ai/models/training-status/{training_job_id}",
                headers=self.headers
            )
            
            progress = progress_response.json()
            print(f"Training progress: {progress.get('progress', 0)}%")
            
            if progress.get('status') == 'completed':
                break
            elif progress.get('status') == 'failed':
                print("Training failed!")
                return False
            
            time.sleep(30)  # Check every 30 seconds
        
        print("Training completed successfully!")
        return True
    
    def exercise_3_model_evaluation(self):
        """Exercise 3: Evaluate model performance"""
        print("\nExercise 3: Model Evaluation")
        
        # Step 1: Get test data
        test_data = self.prepare_test_data()
        
        # Step 2: Run predictions
        prediction_response = requests.post(
            f"{self.dnac_url}/dna/intent/api/v1/ai/models/predict",
            headers=self.headers,
            json={
                "model_name": "lab_anomaly_detector",
                "data": test_data["features"]
            }
        )
        
        predictions = prediction_response.json()["predictions"]
        actual_labels = test_data["labels"]
        
        # Step 3: Calculate performance metrics
        accuracy = accuracy_score(actual_labels, predictions)
        precision = precision_score(actual_labels, predictions, average='weighted')
        recall = recall_score(actual_labels, predictions, average='weighted')
        
        print(f"Model Performance:")
        print(f"  Accuracy: {accuracy:.3f}")
        print(f"  Precision: {precision:.3f}")
        print(f"  Recall: {recall:.3f}")
        
        # Step 4: Performance validation
        if accuracy >= 0.85:
            print("✓ Model meets accuracy requirement (>85%)")
            return True
        else:
            print("✗ Model accuracy below requirement")
            return False
    
    def prepare_training_data(self):
        """Prepare synthetic training data for lab"""
        # Generate synthetic network metrics
        np.random.seed(42)
        
        # Normal network behavior
        normal_data = {
            "interface_utilization": np.random.normal(45, 15, 800).tolist(),
            "cpu_usage": np.random.normal(35, 10, 800).tolist(),
            "memory_usage": np.random.normal(60, 20, 800).tolist(),
            "labels": [0] * 800  # 0 = normal
        }
        
        # Anomalous network behavior
        anomaly_data = {
            "interface_utilization": np.random.normal(85, 10, 200).tolist(),
            "cpu_usage": np.random.normal(90, 5, 200).tolist(),
            "memory_usage": np.random.normal(95, 5, 200).tolist(),
            "labels": [1] * 200  # 1 = anomaly
        }
        
        # Combine data
        training_data = {
            "features": {
                "interface_utilization": normal_data["interface_utilization"] + anomaly_data["interface_utilization"],
                "cpu_usage": normal_data["cpu_usage"] + anomaly_data["cpu_usage"],
                "memory_usage": normal_data["memory_usage"] + anomaly_data["memory_usage"]
            },
            "labels": normal_data["labels"] + anomaly_data["labels"]
        }
        
        return training_data
    
    def prepare_test_data(self):
        """Prepare test data for model evaluation"""
        np.random.seed(123)
        
        # Generate test data similar to training data
        test_features = {
            "interface_utilization": np.random.normal(50, 20, 100).tolist(),
            "cpu_usage": np.random.normal(40, 15, 100).tolist(),
            "memory_usage": np.random.normal(65, 25, 100).tolist()
        }
        
        # Create labels based on thresholds (for testing purposes)
        labels = []
        for i in range(100):
            if (test_features["interface_utilization"][i] > 80 or 
                test_features["cpu_usage"][i] > 80 or
                test_features["memory_usage"][i] > 90):
                labels.append(1)  # anomaly
            else:
                labels.append(0)  # normal
        
        return {"features": test_features, "labels": labels}

# Lab execution
if __name__ == "__main__":
    # Initialize lab environment
    lab = AIModelTrainingLab("https://dnac-lab.company.com", "LAB_TOKEN")
    
    # Execute exercises
    exercises = [
        lab.exercise_1_model_initialization,
        lab.exercise_2_model_training, 
        lab.exercise_3_model_evaluation
    ]
    
    results = []
    for i, exercise in enumerate(exercises, 1):
        print(f"\n{'='*50}")
        print(f"Starting Exercise {i}")
        print(f"{'='*50}")
        
        try:
            result = exercise()
            results.append(result)
            print(f"Exercise {i}: {'PASSED' if result else 'FAILED'}")
        except Exception as e:
            print(f"Exercise {i}: ERROR - {str(e)}")
            results.append(False)
    
    # Lab summary
    print(f"\n{'='*50}")
    print("LAB SUMMARY")
    print(f"{'='*50}")
    passed_exercises = sum(results)
    print(f"Exercises completed: {passed_exercises}/{len(exercises)}")
    print(f"Success rate: {(passed_exercises/len(exercises))*100:.0f}%")
    
    if passed_exercises == len(exercises):
        print("🎉 Congratulations! All exercises completed successfully.")
    else:
        print("⚠️  Some exercises need attention. Review and retry.")
```

### Module 4: ThousandEyes Integration (4 hours)

#### Learning Objectives
- Configure ThousandEyes integration with DNA Center
- Set up internet intelligence monitoring
- Implement end-to-end visibility workflows

#### Content Outline

**4.1 ThousandEyes Platform Overview (1 hour)**
- ThousandEyes architecture and capabilities
- Agent deployment strategies
- Test types and monitoring scenarios

**4.2 Integration Configuration (2 hours)**
- DNA Center and ThousandEyes API integration
- Authentication and security setup
- Data synchronization configuration

**4.3 End-to-End Monitoring Setup (1 hour)**
- Creating comprehensive monitoring workflows
- Correlation rules and automation
- Dashboard integration and reporting

### Module 5: Operations and Troubleshooting (6 hours)

#### Learning Objectives
- Perform daily operational tasks
- Troubleshoot common AI analytics issues
- Optimize system performance

#### Content Outline

**5.1 Daily Operations (2 hours)**
- Health monitoring procedures
- Performance metrics review
- Incident response workflows

**5.2 Troubleshooting Methodology (2 hours)**
- Common issues and root causes
- Diagnostic tools and techniques
- Escalation procedures

**5.3 Performance Optimization (2 hours)**
- System tuning strategies
- AI model optimization
- Resource management

#### Hands-On Lab 5.1: Operations Simulation
```bash
#!/bin/bash
# Lab Exercise: Operations Day Simulation
# Duration: 3 hours

echo "AI Network Analytics Operations Simulation Lab"
echo "=============================================="

LAB_ENVIRONMENT="https://dnac-lab.company.com"
LAB_TOKEN="YOUR_LAB_TOKEN"

# Exercise 1: Daily Health Check Routine
echo "Exercise 1: Performing Daily Health Checks"
echo "==========================================="

perform_health_check() {
    echo "1.1 Checking system health..."
    curl -s -X GET "$LAB_ENVIRONMENT/dna/system/api/v1/health" \
        -H "X-Auth-Token: $LAB_TOKEN" | jq '.health'
    
    echo "1.2 Checking AI analytics status..."
    curl -s -X GET "$LAB_ENVIRONMENT/dna/intent/api/v1/ai-analytics/status" \
        -H "X-Auth-Token: $LAB_TOKEN" | jq '.status'
    
    echo "1.3 Reviewing active alerts..."
    curl -s -X GET "$LAB_ENVIRONMENT/dna/intent/api/v1/alerts" \
        -H "X-Auth-Token: $LAB_TOKEN" | jq '.alerts | length'
    
    echo "1.4 Checking model performance..."
    curl -s -X GET "$LAB_ENVIRONMENT/dna/intent/api/v1/ai/models/performance" \
        -H "X-Auth-Token: $LAB_TOKEN" | jq '.models[].accuracy'
}

# Exercise 2: Incident Investigation Simulation
simulate_incident_investigation() {
    echo "Exercise 2: Investigating Network Anomaly"
    echo "========================================="
    
    echo "2.1 Anomaly detected - High interface utilization"
    echo "2.2 Gathering additional diagnostics..."
    
    # Simulate gathering interface statistics
    curl -s -X GET "$LAB_ENVIRONMENT/dna/intent/api/v1/interface/stats" \
        -H "X-Auth-Token: $LAB_TOKEN" > interface_stats.json
    
    echo "2.3 Running AI root cause analysis..."
    curl -s -X POST "$LAB_ENVIRONMENT/dna/intent/api/v1/ai/root-cause-analysis" \
        -H "X-Auth-Token: $LAB_TOKEN" \
        -d '{"anomaly_id": "SIM_001", "include_recommendations": true}' | \
        jq '.root_cause'
    
    echo "2.4 Reviewing recommended actions..."
    echo "   - Optimize traffic routing"
    echo "   - Implement QoS policies"
    echo "   - Schedule capacity upgrade"
}

# Exercise 3: Performance Optimization
optimize_performance() {
    echo "Exercise 3: Performance Optimization"
    echo "===================================="
    
    echo "3.1 Analyzing system performance..."
    SYSTEM_PERF=$(curl -s -X GET "$LAB_ENVIRONMENT/dna/system/api/v1/performance" \
        -H "X-Auth-Token: $LAB_TOKEN")
    
    CPU_USAGE=$(echo $SYSTEM_PERF | jq '.cpu_usage')
    MEMORY_USAGE=$(echo $SYSTEM_PERF | jq '.memory_usage')
    
    echo "   CPU Usage: $CPU_USAGE%"
    echo "   Memory Usage: $MEMORY_USAGE%"
    
    if (( $(echo "$CPU_USAGE > 75" | bc -l) )); then
        echo "3.2 High CPU detected - Optimizing resources..."
        curl -s -X POST "$LAB_ENVIRONMENT/dna/system/api/v1/optimize/cpu" \
            -H "X-Auth-Token: $LAB_TOKEN" \
            -d '{"optimization_level": "moderate"}'
    fi
    
    echo "3.3 Optimizing AI model parameters..."
    curl -s -X PUT "$LAB_ENVIRONMENT/dna/intent/api/v1/ai/models/optimize" \
        -H "X-Auth-Token: $LAB_TOKEN" \
        -d '{"models": ["anomaly-detection"], "target": "performance"}'
}

# Execute exercises
perform_health_check
echo ""
simulate_incident_investigation
echo ""
optimize_performance

echo ""
echo "Lab Complete!"
echo "Review the outputs and discuss findings with instructor."
```

## Certification Program

### Cisco AI Network Analytics Certification Path

#### Foundation Certification
- **Name**: Cisco AI Network Analytics Foundation (CANAFO)
- **Duration**: 2 days training + exam
- **Prerequisites**: CCNA or equivalent experience
- **Exam Format**: 60 questions, 90 minutes
- **Passing Score**: 825/1000

**Exam Topics**:
1. AI/ML Fundamentals (15%)
2. Cisco AI Analytics Portfolio (25%)
3. Basic Configuration (30%)
4. Operations and Monitoring (20%)
5. Troubleshooting (10%)

#### Professional Certification
- **Name**: Cisco AI Network Analytics Professional (CANAPRO)
- **Duration**: 5 days training + exam
- **Prerequisites**: CANAFO + 6 months experience
- **Exam Format**: 120 questions + lab, 4 hours
- **Passing Score**: 800/1000

**Exam Topics**:
1. Advanced AI Model Configuration (25%)
2. Integration and Automation (20%)
3. Performance Optimization (20%)
4. Security and Compliance (15%)
5. Advanced Troubleshooting (20%)

#### Expert Certification
- **Name**: Cisco AI Network Analytics Expert (CANAEX)
- **Duration**: 8-hour lab exam
- **Prerequisites**: CANAPRO + 18 months experience
- **Exam Format**: Hands-on lab scenarios
- **Passing Score**: 80% of tasks completed

**Lab Scenarios**:
1. Complete AI analytics solution design and deployment
2. Complex troubleshooting and optimization
3. Custom integration development
4. Performance tuning and scaling

### Training Resources

#### Online Learning Platform

**Self-Paced Modules**:
```yaml
learning_platform:
  modules:
    - title: "AI Fundamentals for Network Engineers"
      duration: "4 hours"
      format: "interactive_videos"
      labs: "hands_on_simulations"
      assessment: "progress_quizzes"
    
    - title: "DNA Center AI Configuration"
      duration: "8 hours"
      format: "step_by_step_tutorials"
      labs: "virtual_lab_environment"
      assessment: "practical_exercises"
    
    - title: "Advanced AI Model Tuning"
      duration: "12 hours"
      format: "expert_led_sessions"
      labs: "real_world_scenarios"
      assessment: "peer_reviews"
  
  features:
    - progress_tracking: true
    - mobile_access: true
    - offline_content: true
    - community_forums: true
    - expert_mentoring: available
```

#### Virtual Labs and Simulations

**Lab Environment Specifications**:
- **Cisco DNA Center**: Full-featured lab instance
- **Virtual Network**: 50+ devices with realistic traffic
- **AI Models**: Pre-trained with sample data
- **ThousandEyes**: Integration sandbox environment
- **Duration**: 24/7 access for 30 days per course

#### Reference Materials

**Documentation Library**:
- Configuration guides and best practices
- API reference documentation
- Troubleshooting quick reference cards
- Performance optimization checklists
- Security compliance guidelines

**Video Library**:
- Expert demonstration videos
- Customer success story interviews
- Technical deep-dive sessions
- Troubleshooting walkthrough videos

#### Community and Support

**Learning Community**:
- Discussion forums by topic area
- Study groups and meetups
- Expert office hours (weekly)
- Peer mentoring program
- Success story sharing

**Instructor Support**:
- Email support for course questions
- Virtual office hours (bi-weekly)
- Lab assistance and troubleshooting
- Career guidance and certification advice

## Training Delivery Options

### Instructor-Led Training (ILT)

**Delivery Formats**:
- **In-Person**: Traditional classroom setting
- **Virtual**: Live online instructor-led sessions
- **Hybrid**: Combination of in-person and virtual

**Class Sizes**: 8-16 participants for optimal interaction
**Schedule**: Flexible scheduling options available
**Locations**: Major cities worldwide + virtual delivery

### Custom Training Programs

**Enterprise Training Solutions**:
- Customized curriculum based on specific needs
- On-site delivery at customer locations
- Role-based training tracks
- Integration with customer lab environments
- Follow-up mentoring and support

### Training Assessment and Validation

#### Competency Assessment Framework

**Assessment Methods**:
1. **Knowledge Checks**: Quick quizzes during training
2. **Hands-On Labs**: Practical skill validation
3. **Project Work**: Real-world scenario completion
4. **Peer Reviews**: Collaborative assessment
5. **Instructor Evaluation**: Expert feedback

**Competency Levels**:
- **Novice**: Basic understanding, guided execution
- **Competent**: Independent task completion
- **Proficient**: Complex problem solving
- **Expert**: Teaching and mentoring others

#### Training Effectiveness Measurement

**Metrics and KPIs**:
- Course completion rates
- Assessment scores and pass rates
- Post-training skill assessments
- Job performance improvements
- Certification achievement rates

**Feedback Mechanisms**:
- End-of-course evaluations
- 30-60-90 day follow-up surveys
- Manager feedback on skill application
- Continuous improvement feedback loop

---

**Version**: 1.0  
**Last Updated**: 2025-01-27  
**Document Owner**: Cisco AI Network Analytics Training Team