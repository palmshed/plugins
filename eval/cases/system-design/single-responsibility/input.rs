pub struct OrderProcessor {
    pub inventory: InventoryManager,
    pub payment: PaymentProcessor,
    pub shipping: ShippingService,
    pub notification: NotificationService,
    pub analytics: AnalyticsTracker,
    pub fraud: FraudDetector,
}

impl OrderProcessor {
    pub async fn process_order(&self, order: &Order) -> Result<ProcessedOrder, Error> {
        self.fraud.check(order).await?;
        self.inventory.reserve(order).await?;
        self.payment.charge(order).await?;
        self.shipping.schedule(order).await?;
        self.notification.send_confirmation(order).await?;
        self.analytics.track(order).await?;
        Ok(ProcessedOrder::from(order))
    }
}
