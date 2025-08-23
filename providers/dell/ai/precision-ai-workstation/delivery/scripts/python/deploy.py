#!/usr/bin/env python3
"""
Dell Precision AI Workstation Deployment Script
"""

import os
import subprocess
import logging
import sys
from pathlib import Path

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/var/log/workstation-deploy.log'),
        logging.StreamHandler(sys.stdout)
    ]
)

class WorkstationDeployer:
    def __init__(self):
        self.workstation_model = "Precision-7860"
        self.gpu_model = "RTX-A6000"
        self.ai_frameworks = ["tensorflow", "pytorch", "scikit-learn"]
        
    def run_command(self, command, check=True):
        """Execute shell command with logging"""
        logging.info(f"Executing: {command}")
        try:
            result = subprocess.run(command, shell=True, check=check, 
                                  capture_output=True, text=True)
            if result.stdout:
                logging.info(f"Output: {result.stdout.strip()}")
            return result
        except subprocess.CalledProcessError as e:
            logging.error(f"Command failed: {e}")
            logging.error(f"Error output: {e.stderr}")
            raise
    
    def install_ai_frameworks(self):
        """Install AI/ML frameworks"""
        logging.info("Installing AI/ML frameworks")
        
        conda_env = "ai-workstation"
        frameworks = {
            "tensorflow": "tensorflow-gpu=2.13",
            "pytorch": "pytorch torchvision torchaudio pytorch-cuda=11.8 -c pytorch -c nvidia",
            "scikit-learn": "scikit-learn pandas numpy matplotlib seaborn jupyter"
        }
        
        for framework, packages in frameworks.items():
            if framework in self.ai_frameworks:
                logging.info(f"Installing {framework}")
                cmd = f"conda install -n {conda_env} {packages} -y"
                self.run_command(cmd)
    
    def configure_gpu(self):
        """Configure GPU settings"""
        logging.info("Configuring GPU settings")
        
        # Verify GPU detection
        result = self.run_command("nvidia-smi --query-gpu=name --format=csv,noheader")
        gpu_name = result.stdout.strip()
        logging.info(f"Detected GPU: {gpu_name}")
        
        # Test CUDA
        test_cuda = """
import torch
print(f"CUDA available: {torch.cuda.is_available()}")
print(f"CUDA devices: {torch.cuda.device_count()}")
if torch.cuda.is_available():
    print(f"Device name: {torch.cuda.get_device_name(0)}")
"""
        
        with open("/tmp/test_cuda.py", "w") as f:
            f.write(test_cuda)
        
        self.run_command("python /tmp/test_cuda.py")
    
    def deploy(self):
        """Main deployment process"""
        logging.info("Starting Dell Precision AI Workstation deployment")
        
        try:
            self.install_ai_frameworks()
            self.configure_gpu()
            logging.info("Deployment completed successfully")
            
        except Exception as e:
            logging.error(f"Deployment failed: {e}")
            sys.exit(1)

if __name__ == "__main__":
    deployer = WorkstationDeployer()
    deployer.deploy()