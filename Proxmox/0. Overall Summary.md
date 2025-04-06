# Design of the Home Cloud

1. Ease of Use

- Through the use of SMB file hosting, multiple platforms can use the same storage devices without a lot of maintenance.
- The centralized virtualization makes LXC and Docker containers easy.
- Simple web interfaces are used for administration and monitoring.
- Components can be easily swapped and upgraded.

2. Robustness
- Data are automatically backed up through the use of RAID devices.
- Cluster of containers can organically self repair and allocate resources.

3. Security
- Clear separation of external and local networks.
- Authentication required for external access.
- Important data should be encrypted.

4. Accessibility
- Access and management via local network are as easy as it gets.
- Hosting and applications should be accessible from the public internet.

5. Cost Effectiveness.
- Data robustness should not be compromised by using low cost hardware.
- Cloud resources from external providers should be avoided.
- Contents can be shared without subscription services.
- Should have basic web and email server capabilities.
- Can rely on cellular internet to function.
