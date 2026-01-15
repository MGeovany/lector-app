import SwiftUI

struct PremiumUpsellSheetView: View {
  @EnvironmentObject private var subscription: SubscriptionStore
  @Environment(\.dismiss) private var dismiss
  @Environment(\.colorScheme) private var colorScheme
  @State private var billingCycle: BillingCycle = .monthly
  @State private var selectedPlan: SubscriptionPlan = .free
  @State private var showRestoreAlert: Bool = false
  @State private var restoreMessage: String?

  var body: some View {
    NavigationStack {
      ScrollView(showsIndicators: false) {
        VStack(alignment: .leading, spacing: 18) {
          header
          billingToggle
          planList
          continueButton
          footer
        }
        .padding(.horizontal, 18)
        .padding(.top, 14)
        .padding(.bottom, 22)
      }
      .background(Color(.systemGroupedBackground))
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "xmark")
              .font(.system(size: 20, weight: .regular))
              .foregroundStyle(AppColors.matteBlack)
          }
        }
      }
    }
    .presentationDetents([.medium, .large])
    .presentationDragIndicator(.visible)
    .onAppear {
      // Default selection follows current subscription.
      selectedPlan = subscription.plan
      billingCycle = subscription.plan == .proYearly ? .yearly : .monthly
      Task { await subscription.refreshFromStoreKit() }
    }
    .alert(
      "Subscription",
      isPresented: Binding(
        get: { subscription.lastErrorMessage != nil },
        set: { newValue in if !newValue { /* no-op */  } }
      )
    ) {
      Button("OK", role: .cancel) {}
    } message: {
      Text(subscription.lastErrorMessage ?? "")
    }
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Pick your plan")
        .font(.parkinsansBold(size: 34))
        .foregroundStyle(colorScheme == .dark ? Color.white : AppColors.matteBlack)

      Text(
        "Upgrade for unlimited storage. Pro will include AI features in the next 1–2 months."
      )
      .font(.parkinsans(size: 14, weight: .regular))
      .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.60) : .secondary)
      .fixedSize(horizontal: false, vertical: true)
    }
    .frame(maxWidth: .infinity)
  }

  private var billingToggle: some View {
    Picker("Billing", selection: $billingCycle) {
      Text("Monthly").tag(BillingCycle.monthly)
      Text("Yearly").tag(BillingCycle.yearly)
    }
    .pickerStyle(.segmented)
  }

  private var planList: some View {
    VStack(spacing: 12) {
      PlanCard(
        title: "Free",
        priceText: "$0",
        subtitle: "Basic reading experience.",
        bullets: [
          "\(MAX_STORAGE_MB) MB total storage",
          "Clean reading",
          "Resume where you left off",
        ],
        badgeText: nil,
        isSelected: selectedPlan == .free,
        onTap: { selectedPlan = .free }
      )

      PlanCard(
        title: "Pro",
        priceText: proPriceText,
        subtitle: "Unlimited storage, sync + backup, and AI soon.",
        bullets: [
          "Unlimited storage",
          "Sync + backup",
          "Private stats",
          "Gentle notifications (opt‑in)",
          "AI features in 1–2 months (price will increase)",
        ],
        badgeText: billingCycle == .yearly ? "Popular" : nil,
        isSelected: selectedPlan.isPro,
        onTap: {
          selectedPlan = (billingCycle == .monthly) ? .proMonthly : .proYearly
        }
      )

      PlanCard(
        title: "Founder",
        priceText: founderPriceText,
        subtitle: "A one‑time purchase to support Lector early.",
        bullets: [
          "Everything in Pro",
          "Early access",
          "“Lector Founder” badge",
        ],
        badgeText: "Lifetime",
        isSelected: selectedPlan.isFounder,
        onTap: { selectedPlan = .founderLifetime }
      )
    }
  }

  private var continueButton: some View {
    Button {
      Task {
        await subscription.purchase(selectedPlan)
        if subscription.lastErrorMessage == nil {
          dismiss()
        }
      }
    } label: {
      ZStack {
        if subscription.isPurchasing {
          ProgressView()
            .tint(.white)
        } else {
          Text(selectedPlan == .free ? "Continue" : "Continue")
            .font(.parkinsansBold(size: 16))
        }
      }
      .foregroundStyle(.white)
      .frame(maxWidth: .infinity)
      .padding(.vertical, 16)
      .background(
        AppColors.matteBlack,
        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
      )
    }
    .buttonStyle(.plain)
    .disabled(subscription.isPurchasing)
    .opacity(subscription.isPurchasing ? 0.7 : 1.0)
    .padding(.top, 6)
  }

  private var footer: some View {
    VStack(spacing: 0) {
      Button {
        Task {
          await subscription.restorePurchases()
          if subscription.lastErrorMessage == nil {
            restoreMessage = "Restored."
          }
          showRestoreAlert = true
        }
      } label: {
        Text("Restore purchases")
          .font(.parkinsans(size: 13, weight: .semibold))
          .foregroundStyle(.primary)
      }
      .buttonStyle(.plain)
      .alert("Restore purchases", isPresented: $showRestoreAlert) {
        Button("OK", role: .cancel) {}
      } message: {
        Text(restoreMessage ?? subscription.lastErrorMessage ?? "Done.")
      }

      Text("Recurring billing for Pro. Cancel anytime.")
        .font(.parkinsans(size: 12, weight: .regular))
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity)
  }

  private var proPriceText: String {
    let plan: SubscriptionPlan = billingCycle == .monthly ? .proMonthly : .proYearly
    let price = subscription.priceText(for: plan)
    if let price {
      return billingCycle == .monthly ? "\(price) / month" : "\(price) / year"
    }
    return billingCycle == .monthly ? "$3.99 / month" : "$39 / year"
  }

  private var founderPriceText: String {
    subscription.priceText(for: .founderLifetime) ?? "$70 lifetime"
  }
}

private struct PlanCard: View {
  let title: String
  let priceText: String
  let subtitle: String
  let bullets: [String]
  let badgeText: String?
  let isSelected: Bool
  let onTap: () -> Void

  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    Button(action: onTap) {
      VStack(alignment: .leading, spacing: 10) {
        HStack(alignment: .firstTextBaseline) {
          VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 8) {
              Text(title)
                .font(.parkinsansBold(size: 16))
                .foregroundStyle(colorScheme == .dark ? Color.white : AppColors.matteBlack)

              if let badgeText {
                Text(badgeText)
                  .font(.parkinsansBold(size: 11))
                  .foregroundStyle(colorScheme == .dark ? Color.black : Color.white)
                  .padding(.horizontal, 8)
                  .padding(.vertical, 4)
                  .background(
                    (colorScheme == .dark ? Color.white : AppColors.matteBlack),
                    in: Capsule(style: .continuous)
                  )
              }
            }

            Text(subtitle)
              .font(.parkinsans(size: 12, weight: .regular))
              .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.55) : .secondary)
          }

          Spacer(minLength: 0)

          VStack(alignment: .trailing, spacing: 2) {
            Text(priceText)
              .font(.parkinsansBold(size: 14))
              .foregroundStyle(colorScheme == .dark ? Color.white : AppColors.matteBlack)

            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
              .font(.system(size: 16, weight: .semibold))
              .foregroundStyle(isSelected ? AppColors.matteBlack : Color(.separator))
          }
        }

        VStack(alignment: .leading, spacing: 6) {
          ForEach(bullets, id: \.self) { text in
            HStack(alignment: .top, spacing: 8) {
              Circle()
                .fill(
                  colorScheme == .dark ? Color.white.opacity(0.35) : Color(.separator).opacity(0.6)
                )
                .frame(width: 5, height: 5)
                .padding(.top, 6)

              Text(text)
                .font(.parkinsans(size: 13, weight: .regular))
                .foregroundStyle(colorScheme == .dark ? Color.white.opacity(0.75) : .secondary)
                .fixedSize(horizontal: false, vertical: true)
            }
          }
        }
      }
      .padding(14)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(
        RoundedRectangle(cornerRadius: 16, style: .continuous)
          .fill(colorScheme == .dark ? Color.white.opacity(0.06) : Color(.systemBackground))
      )
      .overlay(
        RoundedRectangle(cornerRadius: 16, style: .continuous)
          .stroke(
            isSelected
              ? (colorScheme == .dark
                ? Color.white.opacity(0.35) : AppColors.matteBlack.opacity(0.65))
              : (colorScheme == .dark
                ? Color.white.opacity(0.10) : Color(.separator).opacity(0.35)),
            lineWidth: isSelected ? 1.5 : 1
          )
      )
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  PremiumUpsellSheetView()
    .environmentObject(SubscriptionStore())
}
