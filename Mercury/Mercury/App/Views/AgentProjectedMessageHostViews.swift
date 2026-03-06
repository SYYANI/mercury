import SwiftUI

struct AgentReaderBannerHostView: View {
    let message: AgentHostRenderedMessageModel
    let onPrimaryAction: (() -> Void)?
    let onSecondaryAction: (() -> Void)?
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: iconName)
                .foregroundStyle(iconColor)
            VStack(alignment: .leading, spacing: message.secondaryText == nil ? 0 : 2) {
                Text(message.primaryText)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .textSelection(.enabled)
                if let secondaryText = message.secondaryText {
                    Text(secondaryText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .textSelection(.enabled)
                }
            }
            Spacer(minLength: 0)
            if let secondaryActionLabel = message.secondaryActionLabel,
               let onSecondaryAction {
                Button(secondaryActionLabel, action: onSecondaryAction)
                    .buttonStyle(.link)
                    .font(.subheadline)
            }
            if let primaryActionLabel = message.primaryActionLabel,
               let onPrimaryAction {
                Button(primaryActionLabel, action: onPrimaryAction)
                    .buttonStyle(.link)
                    .font(.subheadline)
            }
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var iconName: String {
        switch message.severity {
        case .info:
            return "info.circle"
        case .success:
            return "checkmark.circle"
        case .warning:
            return "exclamationmark.triangle"
        case .error:
            return "xmark.octagon"
        }
    }

    private var iconColor: Color {
        switch message.severity {
        case .info:
            return .secondary
        case .success:
            return .green
        case .warning:
            return ViewSemanticStyle.warningColor
        case .error:
            return ViewSemanticStyle.errorColor
        }
    }
}

struct AgentBatchSheetFooterMessageView: View {
    let message: AgentHostRenderedMessageModel
    let onPrimaryAction: (() -> Void)?
    let onSecondaryAction: (() -> Void)?

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: iconName)
                .foregroundStyle(iconColor)
            VStack(alignment: .leading, spacing: message.secondaryText == nil ? 0 : 2) {
                Text(message.primaryText)
                    .font(.footnote)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if let secondaryText = message.secondaryText {
                    Text(secondaryText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if let secondaryActionLabel = message.secondaryActionLabel,
               let onSecondaryAction {
                Button(secondaryActionLabel, action: onSecondaryAction)
                    .buttonStyle(.link)
                    .font(.footnote)
            }
            if let primaryActionLabel = message.primaryActionLabel,
               let onPrimaryAction {
                Button(primaryActionLabel, action: onPrimaryAction)
                    .buttonStyle(.link)
                    .font(.footnote)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var iconName: String {
        switch message.severity {
        case .info:
            return "info.circle"
        case .success:
            return "checkmark.circle"
        case .warning:
            return "exclamationmark.triangle"
        case .error:
            return "xmark.octagon"
        }
    }

    private var iconColor: Color {
        switch message.severity {
        case .info:
            return .secondary
        case .success:
            return .green
        case .warning:
            return ViewSemanticStyle.warningColor
        case .error:
            return ViewSemanticStyle.errorColor
        }
    }
}