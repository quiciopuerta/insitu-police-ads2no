import React, { useState } from 'react';
import { NamingBuilder } from './NamingBuilder';
import { LiveBudgetControl } from './LiveBudgetControl';
import { User } from '../../types';

interface GovernanceDashboardProps {
  currentUser: User;
  language: 'es' | 'en';
}

export const GovernanceDashboard: React.FC<GovernanceDashboardProps> = ({ currentUser, language }) => {
  const [activeSubTab, setActiveSubTab] = useState<'naming' | 'budget'>('naming');
  const L = (es: string, en: string) => language === 'es' ? es : en;

  return (
    <div className="space-y-6">
      <div className="flex flex-col md:flex-row md:items-end justify-between gap-4">
        <div>
          <h2 className="text-3xl font-black text-white flex items-center gap-3">
            <span className="material-symbols-outlined text-4xl text-[#ff477b]">account_balance</span>
            {L('Gobernanza & CRM', 'Governance & CRM')}
          </h2>
          <p className="text-slate-400 mt-2">
            {L('Estructura tus campañas y sincronízalas directamente con crm.insitu.company.', 'Structure your campaigns and sync them directly with crm.insitu.company.')}
          </p>
        </div>
        
        <button 
          className="bg-emerald-500 hover:bg-emerald-400 text-white px-6 py-3 rounded-full font-bold flex items-center gap-2 transition-all transform hover:scale-105"
        >
          <span className="material-symbols-outlined">sync</span>
          {L('Sincronizar CRM', 'Sync CRM')}
        </button>
      </div>

      <div className="flex space-x-2 border-b border-slate-700/50 mb-6">
        <button
          onClick={() => setActiveSubTab('naming')}
          className={`px-4 py-2 font-bold text-sm uppercase transition-colors border-b-2 ${
            activeSubTab === 'naming' 
              ? 'border-[#ff477b] text-[#ff477b]' 
              : 'border-transparent text-slate-500 hover:text-slate-300'
          }`}
        >
          {L('Nomenclatura & UTMs', 'Naming & UTMs')}
        </button>
        <button
          onClick={() => setActiveSubTab('budget')}
          className={`px-4 py-2 font-bold text-sm uppercase transition-colors border-b-2 ${
            activeSubTab === 'budget' 
              ? 'border-[#ff477b] text-[#ff477b]' 
              : 'border-transparent text-slate-500 hover:text-slate-300'
          }`}
        >
          {L('Control Presupuestario', 'Budget Control')}
        </button>
      </div>

      {activeSubTab === 'naming' && (
        <NamingBuilder language={language} />
      )}
      
      {activeSubTab === 'budget' && (
        <LiveBudgetControl currentUser={currentUser} language={language} />
      )}
    </div>
  );
};
