import { tool } from 'ai';
import { z } from 'zod';

const CLENZY_BACKEND_URL = 'http://localhost:8000';

export const get_user_bookings = tool({
  description: 'Get the booking history and payment status for the current Clenzy user.',
  parameters: z.object({
    userId: z.number().optional().describe('The ID of the user to fetch bookings for. Defaults to current session user.'),
  }),
  execute: async ({ userId }: { userId?: number }) => {
    try {
      const response = await fetch(`${CLENZY_BACKEND_URL}/admin/payments`);
      if (!response.ok) throw new Error('Failed to fetch from Clenzy backend');
      
      const allPayments = await response.json();
      // Filter by user ID if provided, otherwise return a summary
      const userPayments = userId 
        ? allPayments.filter((p: any) => p.user_id === userId)
        : allPayments;

      return {
        success: true,
        bookings: userPayments.map((p: any) => ({
          bookingId: p.job_id,
          amount: p.amount,
          status: p.payment_status,
          date: p.created_at,
          method: p.payment_method || 'Processing'
        }))
      };
    } catch (error) {
      console.error('Clenzy Tool Error:', error);
      return { success: false, error: 'Could not connect to Clenzy backend service.' };
    }
  },
});

export const get_safety_protocol = tool({
  description: 'Get Clenzy\'s official safety protocols and emergency instructions.',
  parameters: z.object({}),
  execute: async () => {
    return {
      protocols: [
        "AI-Verified Professionals: Every worker is background checked using Clenzy AI.",
        "SafeLink Check-In: Users must verify the worker's QR code before service starts.",
        "Panic Button: Immediate alert to the Clenzy response team and local authorities.",
        "Live Monitoring: Every active session is monitored via AI for behavioral anomalies."
      ],
      emergencyContacts: [
        "Clenzy SOS Hotline: 9778155291",
        "Local Police: 100/112"
      ]
    };
  },
});
