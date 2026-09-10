import React, { useState, useEffect } from 'react';
import { User } from '../../types';
import { googleAdsService } from '../../services/googleAdsService';

interface LiveBudgetControlProps {
  currentUser: User;
  language: 'es' | 'en';
}

interface CampaignSpend {
  id: string;
  name: string;
  status: string;
  cost: number;
  clicks: number;
  conversions: number;
}

export const LiveBudgetControl: React.FC<LiveBudgetControlProps> = ({ currentUser, language }) => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [campaigns, setCampaigns] = useState<CampaignSpend[]>([]);
  const [totalSpend, setTotalSpend] = useState(0);
  const [plannedBudget, setPlannedBudget] = useState(5000); // Mock planned budget

  const L = (es: string, en: string) => language === 'es' ? es : en;

  const fetchRealSpend = async () => {
    setLoading(true);
    setError(null);
    try {
      // In a real scenario we use googleAdsService. Here we call the API proxy directly.
      const response = await fetch('/.netlify/functions/api-google-ads', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ 
          action: 'getCampaigns',
          customerId: '0000000000', // Mock fallback customer ID to trigger real API check
          userId: currentUser.id
        })
      });
      
      const data = await response.json();
      
      if (!response.ok) {
        throw new Error(data.error || 'Error fetching spend data from Google Ads API');
      }

      // getCampaigns returns an array of objects directly in some paths or { campaigns: [...] }
      const fetchedCampaigns = Array.isArray(data) ? data : data.campaigns || [];
      
      const mappedCampaigns: CampaignSpend[] = fetchedCampaigns.map((c: any, index: number) => ({
        id: String(index),
        name: c.campaignName,
        status: 'ENABLED',
        cost: c.cost,
        clicks: c.clicks,
        conversions: c.conversions
      }));

      setCampaigns(mappedCampaigns);
      const total = mappedCampaigns.reduce((acc, curr) => acc + curr.cost, 0);
      setTotalSpend(total);

    } catch (err: any) {
      console.warn("Using mock data since API failed:", err.message);
      setError(L('No se pudo conectar a Google Ads API (Falta Token). Mostrando datos de prueba.', 'Could not connect to Google Ads API (Missing Token). Showing mock data.'));
      
      // Fallback to mock data if API is not fully configured
      const mockData = [
        { id: '1', name: 'SEARCH_LATAM_LEADS_BOFU', status: 'ENABLED', cost: 1250.50, clicks: 450, conversions: 12 },
        { id: '2', name: 'META_MX_SALES_MOFU', status: 'ENABLED', cost: 890.00, clicks: 310, conversions: 8 },
        { id: '3', name: 'PMAX_GLOBAL_AWARENESS_TOFU', status: 'PAUSED', cost: 350.25, clicks: 890, conversions: 2 }
      ];
      setCampaigns(mockData);
      setTotalSpend(mockData.reduce((acc, curr) => acc + curr.cost, 0));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchRealSpend();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const pacingPercentage = Math.min((totalSpend / plannedBudget) * 100, 100);
  const isOverspending = totalSpend > plannedBudget;

  return (
    <div className="space-y-6">
      {/* Overview Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-slate-800/50 rounded-2xl border border-slate-700 p-6">
          <p className="text-sm text-slate-400 font-bold uppercase mb-1">{L('Presupuesto Planificado', 'Planned Budget')}</p>
          <div className="text-3xl font-black text-white">${plannedBudget.toLocaleString()}</div>
          <p className="text-xs text-slate-500 mt-2">{L('Asignado en INsitu CRM', 'Allocated in INsitu CRM')}</p>
        </div>
        
        <div className="bg-slate-800/50 rounded-2xl border border-slate-700 p-6 relative overflow-hidden">
          <p className="text-sm text-slate-400 font-bold uppercase mb-1">{L('Gasto Real (Redes)', 'Real Spend (Networks)')}</p>
          <div className="text-3xl font-black text-emerald-400">${totalSpend.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}</div>
          <p className="text-xs text-slate-500 mt-2">{L('Extraído de las APIs en vivo', 'Pulled from live APIs')}</p>
          {loading && (
            <div className="absolute top-0 left-0 w-full h-1 bg-emerald-500/20">
              <div className="h-full bg-emerald-500 w-1/3 animate-[slide_2s_ease-in-out_infinite]" />
            </div>
          )}
        </div>

        <div className="bg-slate-800/50 rounded-2xl border border-slate-700 p-6">
          <p className="text-sm text-slate-400 font-bold uppercase mb-1">{L('Pacing (Ritmo de Gasto)', 'Spend Pacing')}</p>
          <div className={`text-3xl font-black ${isOverspending ? 'text-red-400' : 'text-amber-300'}`}>
            {((totalSpend / plannedBudget) * 100).toFixed(1)}%
          </div>
          
          <div className="w-full bg-slate-900 rounded-full h-2 mt-3 overflow-hidden">
            <div 
              className={`h-2 rounded-full ${isOverspending ? 'bg-red-500' : 'bg-amber-400'}`} 
              style={{ width: `${pacingPercentage}%` }}
            />
          </div>
        </div>
      </div>

      {error && (
        <div className="bg-amber-500/10 border border-amber-500/20 text-amber-300 px-4 py-3 rounded-lg text-sm flex items-start gap-3">
          <span className="material-symbols-outlined text-xl">warning</span>
          <p>{error}</p>
        </div>
      )}

      {/* Campaigns Table */}
      <div className="bg-slate-800/50 rounded-2xl border border-slate-700 overflow-hidden">
        <div className="p-4 border-b border-slate-700 bg-slate-900/50 flex justify-between items-center">
          <h3 className="font-bold text-white">{L('Desglose por Campaña', 'Campaign Breakdown')}</h3>
          <button 
            onClick={fetchRealSpend}
            disabled={loading}
            className="text-slate-400 hover:text-white transition-colors"
          >
            <span className={`material-symbols-outlined ${loading ? 'animate-spin' : ''}`}>refresh</span>
          </button>
        </div>
        
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse">
            <thead>
              <tr className="bg-slate-900/80 text-xs uppercase text-slate-500">
                <th className="p-4 font-bold">{L('Campaña', 'Campaign')}</th>
                <th className="p-4 font-bold">{L('Estado', 'Status')}</th>
                <th className="p-4 font-bold text-right">{L('Gasto', 'Spend')}</th>
                <th className="p-4 font-bold text-right">{L('Clics', 'Clicks')}</th>
                <th className="p-4 font-bold text-right">{L('Conversiones', 'Conversions')}</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-700/50 text-sm">
              {campaigns.map((camp) => (
                <tr key={camp.id} className="hover:bg-slate-700/30 transition-colors">
                  <td className="p-4">
                    <div className="font-mono text-emerald-400 text-xs">{camp.name}</div>
                  </td>
                  <td className="p-4">
                    <span className={`px-2 py-1 rounded text-[10px] font-bold uppercase tracking-wider ${
                      camp.status === 'ENABLED' ? 'bg-emerald-500/20 text-emerald-300' : 'bg-slate-700 text-slate-400'
                    }`}>
                      {camp.status}
                    </span>
                  </td>
                  <td className="p-4 text-right font-bold text-white">
                    ${camp.cost.toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })}
                  </td>
                  <td className="p-4 text-right text-slate-300">{camp.clicks.toLocaleString()}</td>
                  <td className="p-4 text-right text-slate-300">{camp.conversions.toLocaleString()}</td>
                </tr>
              ))}
              {campaigns.length === 0 && !loading && (
                <tr>
                  <td colSpan={5} className="p-8 text-center text-slate-500">
                    {L('No hay campañas activas o no se encontraron datos.', 'No active campaigns or data found.')}
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};
