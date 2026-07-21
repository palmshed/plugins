# Single responsibility violation

OrderProcessor orchestrates fraud detection, inventory, payment, shipping, notifications, and analytics. This violates single responsibility and makes the class hard to maintain and test.

Each responsibility should be handled by a dedicated service, with OrderProcessor acting as a thin orchestrator.
