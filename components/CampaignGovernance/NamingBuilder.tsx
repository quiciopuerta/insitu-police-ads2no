import React, { useState, useEffect } from 'react';

interface NamingBuilderProps {
  language: 'es' | 'en';
}

const NETWORKS = ['Google Ads', 'Meta Ads', 'TikTok Ads', 'LinkedIn Ads'];
const GOALS = ['Leads', 'Sales', 'Traffic', 'Awareness', 'App Installs'];
const REGIONS = ['LATAM', 'US', 'EU', 'GLOBAL', 'CO', 'MX', 'AR', 'ES'];
const FUNNEL_STAGES = ['TOFU (Awareness)', 'MOFU (Consideration)', 'BOFU (Conversion)', 'Retention'];

export const NamingBuilder: React.FC<NamingBuilderProps> = ({ language }) => {
  const [network, setNetwork] = useState(NETWORKS[0]);
  const [goal, setGoal] = useState(GOALS[0]);
  const [region, setRegion] = useState(REGIONS[0]);
  const [funnel, setFunnel] = useState(FUNNEL_STAGES[0]);
  const [campaignName, setCampaignName] = useState('');
  const [customIdentifier, setCustomIdentifier] = useState('');
  const [destinationUrl, setDestinationUrl] = useState('https://insitu.company');
  const [finalUrl, setFinalUrl] = useState('');

  const L = (es: string, en: string) => language === 'es' ? es : en;

  // Generate Campaign Name
  useEffect(() => {
    const netCode = network.split(' ')[0].toUpperCase();
    const funnelCode = funnel.split(' ')[0];
    const identifier = customIdentifier ? `_${customIdentifier.toUpperCase().replace(/\s+/g, '-')}` : '';
    const generated = `${netCode}_${region}_${goal.toUpperCase()}_${funnelCode}${identifier}`;
    setCampaignName(generated);
  }, [network, goal, region, funnel, customIdentifier]);

  // Generate UTMs
  useEffect(() => {
    try {
      const url = new URL(destinationUrl || 'https://example.com');
      url.searchParams.set('utm_source', network.toLowerCase().replace(' ', '_'));
      url.searchParams.set('utm_medium', 'cpc');
      url.searchParams.set('utm_campaign', campaignName.toLowerCase());
      
      // Dynamic parameters based on network
      if (network === 'Google Ads') {
        url.searchParams.set('utm_term', '{keyword}');
        url.searchParams.set('utm_content', '{creative}');
      } else if (network === 'Meta Ads') {
        url.searchParams.set('utm_content', '{{ad.name}}');
      }
      
      setFinalUrl(url.toString());
    } catch (e) {
      setFinalUrl(L('URL de destino inválida', 'Invalid destination URL'));
    }
  }, [campaignName, destinationUrl, network, language]);

  return (
    <div className="bg-slate-800/50 rounded-2xl border border-slate-700 p-6 space-y-6">
      <div>
        <h3 className="text-xl font-bold text-white flex items-center gap-2">
          <span className="material-symbols-outlined text-[#ff477b]">account_tree</span>
          {L('Taxonomía & UTM Builder', 'Taxonomy & UTM Builder')}
        </h3>
        <p className="text-slate-400 text-sm mt-1">
          {L('Estandariza los nombres de tus campañas para un tracking perfecto en el CRM.', 'Standardize your campaign names for perfect CRM tracking.')}
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {/* Network */}
        <div>
          <label className="block text-xs font-bold text-slate-400 uppercase mb-2">{L('Red / Plataforma', 'Network / Platform')}</label>
          <select 
            value={network}
            onChange={(e) => setNetwork(e.target.value)}
            className="w-full bg-slate-900 border border-slate-700 rounded-lg px-4 py-2 text-white text-sm focus:outline-none focus:border-[#ff477b]"
          >
            {NETWORKS.map(n => <option key={n} value={n}>{n}</option>)}
          </select>
        </div>

        {/* Goal */}
        <div>
          <label className="block text-xs font-bold text-slate-400 uppercase mb-2">{L('Objetivo', 'Goal')}</label>
          <select 
            value={goal}
            onChange={(e) => setGoal(e.target.value)}
            className="w-full bg-slate-900 border border-slate-700 rounded-lg px-4 py-2 text-white text-sm focus:outline-none focus:border-[#ff477b]"
          >
            {GOALS.map(g => <option key={g} value={g}>{g}</option>)}
          </select>
        </div>

        {/* Region */}
        <div>
          <label className="block text-xs font-bold text-slate-400 uppercase mb-2">{L('Región', 'Region')}</label>
          <select 
            value={region}
            onChange={(e) => setRegion(e.target.value)}
            className="w-full bg-slate-900 border border-slate-700 rounded-lg px-4 py-2 text-white text-sm focus:outline-none focus:border-[#ff477b]"
          >
            {REGIONS.map(r => <option key={r} value={r}>{r}</option>)}
          </select>
        </div>

        {/* Funnel */}
        <div>
          <label className="block text-xs font-bold text-slate-400 uppercase mb-2">{L('Fase del Funnel', 'Funnel Stage')}</label>
          <select 
            value={funnel}
            onChange={(e) => setFunnel(e.target.value)}
            className="w-full bg-slate-900 border border-slate-700 rounded-lg px-4 py-2 text-white text-sm focus:outline-none focus:border-[#ff477b]"
          >
            {FUNNEL_STAGES.map(f => <option key={f} value={f}>{f}</option>)}
          </select>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div>
          <label className="block text-xs font-bold text-slate-400 uppercase mb-2">{L('Identificador Custom (Opcional)', 'Custom Identifier (Optional)')}</label>
          <input 
            type="text" 
            placeholder={L('Ej: BLACKFRIDAY, Q4, PROMO', 'Ex: BLACKFRIDAY, Q4, PROMO')}
            value={customIdentifier}
            onChange={(e) => setCustomIdentifier(e.target.value)}
            className="w-full bg-slate-900 border border-slate-700 rounded-lg px-4 py-2 text-white text-sm focus:outline-none focus:border-[#ff477b]"
          />
        </div>
        <div>
          <label className="block text-xs font-bold text-slate-400 uppercase mb-2">{L('URL de Destino (Landing Page)', 'Destination URL (Landing Page)')}</label>
          <input 
            type="url" 
            value={destinationUrl}
            onChange={(e) => setDestinationUrl(e.target.value)}
            className="w-full bg-slate-900 border border-slate-700 rounded-lg px-4 py-2 text-white text-sm focus:outline-none focus:border-[#ff477b]"
          />
        </div>
      </div>

      {/* Results */}
      <div className="mt-8 p-4 bg-[#ff477b]/10 border border-[#ff477b]/20 rounded-xl space-y-4">
        <div>
          <p className="text-xs font-bold text-[#ff477b] uppercase">{L('Nombre de Campaña Generado', 'Generated Campaign Name')}</p>
          <div className="mt-1 flex items-center justify-between bg-slate-950 p-3 rounded-lg border border-slate-800">
            <code className="text-emerald-400 font-mono text-sm break-all">{campaignName}</code>
            <button 
              onClick={() => navigator.clipboard.writeText(campaignName)}
              className="ml-4 text-slate-400 hover:text-white transition-colors"
              title="Copy"
            >
              <span className="material-symbols-outlined text-sm">content_copy</span>
            </button>
          </div>
        </div>

        <div>
          <p className="text-xs font-bold text-[#ff477b] uppercase">{L('URL Final con UTMs', 'Final URL with UTMs')}</p>
          <div className="mt-1 flex items-center justify-between bg-slate-950 p-3 rounded-lg border border-slate-800">
            <code className="text-amber-300 font-mono text-sm break-all">{finalUrl}</code>
            <button 
              onClick={() => navigator.clipboard.writeText(finalUrl)}
              className="ml-4 text-slate-400 hover:text-white transition-colors"
              title="Copy"
            >
              <span className="material-symbols-outlined text-sm">content_copy</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
