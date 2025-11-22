# Azure Virtual Desktop - Architecture Diagram

## Key Components
1. **Host Pools** - Collections of session host VMs (pooled or personal)
2. **Session Hosts** - Windows VMs running multi-session or single-session
3. **FSLogix Profiles** - User profiles on Azure Files with Premium tier
4. **Azure AD** - User authentication and Conditional Access
5. **Virtual Network** - Secure network with NSGs and private connectivity

## Flow
```
1. User authenticates → Microsoft Entra ID (Azure AD)
2. AVD service broker → Allocates session to available host
3. User connects → Session host VM via RD Gateway
4. Profile loads → From Azure Files (FSLogix container)
5. Monitor tracks → Session performance and user experience
```
